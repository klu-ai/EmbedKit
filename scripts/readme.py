#!/usr/bin/env python3
"""
README Generator for EmbedKit

This script automatically generates a comprehensive README.md file for the EmbedKit project
by analyzing the codebase and using Google's Gemini AI to create well-structured documentation.

Key features:
- Efficiently extracts content from all tracked files in the git repository
- Uses parallel processing for faster file reading when dealing with large codebases
- Implements error handling and logging for robust execution
- Leverages Gemini AI to generate a comprehensive README with proper formatting
- Preserves existing README structure while updating content

Usage:
    python3 scripts/update_readme.py

Requirements:
    - google-generativeai package
    - Git repository
    - GEMINI_API_KEY environment variable
"""

import os
import subprocess
import concurrent.futures
from pathlib import Path
from typing import Optional, Tuple
from google import genai

# The system prompt instructs the model on what to do
SYSTEM_PROMPT = """You are a helpful developer relations assistant that reads the entire code base and rewrites the README.md file to provide clear instructions, describe the package, list dependencies, and usage examples. Please analyze the code and produce an updated README that maintains a professional developer relations tone, does not use emojis, and includes all necessary information for users to understand and use the package. Output README.md ready for deployment to GitHub. DO NOT WRAP entire output in ```markdown``` tags it's not necessary."""

# AI model configuration
AI_MODEL = 'gemini-2.0-flash-thinking-exp-01-21'

def read_file_content(file_path: str) -> Tuple[str, str]:
    """
    Reads the content of a single file with proper error handling.
    
    Args:
        file_path: Path to the file to read
        
    Returns:
        Tuple containing the file path and its content or error message
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        return file_path, content
    except UnicodeDecodeError:
        # Handle binary files
        return file_path, "[Binary file]"
    except Exception as e:
        print(f"Warning: Error reading {file_path}: {e}")
        return file_path, f"[Error reading file: {e}]"

def get_codebase_summary() -> str:
    """
    Generates a summary of the codebase by listing tracked files and their content.
    Uses parallel processing for improved performance with large codebases.
    
    Returns:
        A string containing the formatted content of all tracked files
    """
    print("Gathering codebase information...")
    
    try:
        # Get list of all tracked files in the git repository
        files = subprocess.check_output(
            ["git", "ls-files"], 
            stderr=subprocess.PIPE
        ).decode("utf-8").splitlines()
    except subprocess.CalledProcessError as e:
        print(f"Error: Git command failed: {e}")
        return "Error: Failed to list git files"
    
    # Use parallel processing to read files more efficiently
    summary = ""
    with concurrent.futures.ThreadPoolExecutor() as executor:
        # Process files in parallel
        results = list(executor.map(read_file_content, files))
        
        # Sort results by filename for consistent output
        results.sort(key=lambda x: x[0])
        
        # Build the summary string
        for file_path, content in results:
            summary += f"--- {file_path} ---\n{content}\n\n"
    
    print(f"Processed {len(files)} files from the codebase")
    return summary

def call_geminiai(prompt: str) -> Optional[str]:
    """
    Uses the Google GenAI Python SDK with Gemini to generate an updated README.
    
    Args:
        prompt: The complete prompt including system instructions and codebase context
        
    Returns:
        Generated README content or None if generation failed
    """
    print(f"Calling Gemini AI ({AI_MODEL}) to generate README...")
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set")
        return None
    
    try:
        # Initialize the Gemini client
        client = genai.Client(api_key=api_key)
        
        # Generate content with the AI model
        response = client.models.generate_content(
            model=AI_MODEL, 
            contents=prompt
        )
        
        print("Successfully generated README content")
        return response.text
    except Exception as e:
        print(f"Error calling Gemini AI: {e}")
        return None

def backup_existing_readme() -> bool:
    """
    Creates a backup of the existing README.md file if it exists.
    
    Returns:
        True if backup was created or not needed, False if backup failed
    """
    readme_path = Path("README.md")
    if readme_path.exists():
        try:
            backup_path = Path("README.md.bak")
            with open(readme_path, "r", encoding="utf-8") as src:
                with open(backup_path, "w", encoding="utf-8") as dst:
                    dst.write(src.read())
            print(f"Created backup at {backup_path}")
            return True
        except Exception as e:
            print(f"Error: Failed to create README backup: {e}")
            return False
    return True  # No existing README to backup

def main() -> None:
    """
    Main function that orchestrates the README generation process:
    1. Backs up existing README
    2. Gathers codebase context
    3. Calls Gemini AI to generate new README
    4. Writes the updated README to disk
    """
    print("Starting README generation process")
    
    # Backup existing README
    if not backup_existing_readme():
        print("Error: Aborting due to backup failure")
        return
    
    # Gather codebase context to inform the README generation
    codebase_context = get_codebase_summary()
    
    # Build the user prompt with the context from the codebase
    full_prompt = f"{SYSTEM_PROMPT}\n\nCodebase files:\n{codebase_context}"
    
    # Generate new README content
    updated_readme = call_geminiai(full_prompt)
    
    # Write the updated README to disk
    if updated_readme:
        try:
            with open("README.md", "w", encoding="utf-8") as f:
                f.write(updated_readme)
            print("README.md has been successfully updated")
        except Exception as e:
            print(f"Error: Failed to write README.md: {e}")
    else:
        print("Error: Failed to generate updated README content")

if __name__ == "__main__":
    main()