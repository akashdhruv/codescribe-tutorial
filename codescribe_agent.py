"""
CodeScribe Automation Agent - Fortran to C++ Translation

REQUIREMENTS:
- pip install smolagents requests
- Argonne VPN connection 
- Set ARGO_ANL_USER below (line 43) to your ANL username

TWO MODES:

MODE 1: WITH CODE-SCRIBE (Recommended for domain-specific translation)
  Setup:
    1. Install code-scribe and ensure it's in PATH
    2. Place translate_prompt.toml and update_prompt.toml in project root
    3. Set task = translation_with_codescribe (line 286)

  Agent calls code-scribe with your .toml configs, runs builds, fixes errors.

MODE 2: DIRECT TRANSLATION BY LLM (No code-scribe needed)
  Setup:
    1. Set task = direct_agent_translation (line 286)

  Argo GPT-5 Mini translates Fortran to C++ directly,
  creates Makefile, runs builds, and fixes errors iteratively.

USAGE:
  cd your_project_directory
  python codescribe_agent.py

Original Author: Jenny Coburn
"""

from smolagents import CodeAgent, tool
from smolagents.models import ChatMessage
import subprocess
import os
import requests

ARGO_ANL_USER = os.getenv("ARGO_USER")
ARGO_API_ENDPOINT = os.getenv("ARGO_API_ENDPOINT")

class ArgoGPT5Mini:
    def __init__(self):
        self.model_name = "gpt5mini"

    def generate(self, messages, stop_sequences=None, grammar=None, **kwargs):
        formatted_messages = []
        for msg in messages:
            role = msg.role if hasattr(msg, 'role') else msg.get('role', 'user')
            content = msg.content if hasattr(msg, 'content') else msg.get('content', '')

            if role == 'tool-call':
                role = 'assistant'
            elif role == 'tool-response':
                role = 'user'

            formatted_messages.append({"role": role, "content": content})

        payload = {
            "user": ARGO_ANL_USER,
            "model": self.model_name,
            "messages": formatted_messages,
            "temperature": 0.7,
            "top_p": 0.9,
            "max_completion_tokens": 4000
        }

        try:
            response = requests.post(ARGO_API_ENDPOINT, json=payload)
            response.raise_for_status()
        except requests.exceptions.HTTPError:
            print(f"ERROR: Argo API failed - Status: {response.status_code}")
            print(f"Response: {response.text}")
            raise

        result = response.json()
        return ChatMessage(role="assistant", content=result["response"])


@tool
def execute_code_scribe(command: str) -> str:
    """
    Execute code-scribe commands for Fortran to C++ translation.

    Available commands:
    - draft <fortran_file>
        Generate initial translation draft
        Example: 'draft src/Initialize.F90'

    - translate <fortran_file> -p <config.toml>
        Translate Fortran to C++ using config file
        Example: 'translate src/Initialize.F90 -p translate_prompt.toml'

    - update <files...> -p <prompt_or_config>
        Update/integrate C++ files and Makefile
        Example: 'update src/main.cpp Makefile -p update_prompt.toml'
        Example: 'update src/main.cpp Makefile -p "fix linker errors"'

    Args:
        command: code-scribe command without 'code-scribe' prefix
    """
    full_command = f"code-scribe {command}"
    result = subprocess.run(
        full_command,
        shell=True,
        capture_output=True,
        text=True,
        cwd=os.getcwd()
    )

    output = f"Command: {full_command}\nExit Code: {result.returncode}\n"
    output += f"\nSTDOUT:\n{result.stdout}\n"
    if result.stderr:
        output += f"STDERR:\n{result.stderr}\n"
    return output


@tool
def run_build(build_command: str = "make") -> str:
    """
    Run build commands and capture output.

    Args:
        build_command: Build command to run (default: 'make')
    """
    result = subprocess.run(
        build_command,
        shell=True,
        capture_output=True,
        text=True,
        cwd=os.getcwd()
    )

    status = "BUILD SUCCESSFUL" if result.returncode == 0 else "BUILD FAILED"
    output = f"Build Command: {build_command}\nExit Code: {result.returncode}\n\n{status}\n"
    output += f"\nSTDOUT:\n{result.stdout}\n"
    if result.stderr:
        output += f"STDERR:\n{result.stderr}\n"
    return output


@tool
def read_source_file(file_path: str) -> str:
    """
    Read a source file.

    Args:
        file_path: Path to file (e.g., 'src/Initialize.F90')
    """
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        return f"File: {file_path}\nSize: {len(content)} bytes\n\n{content}"
    except FileNotFoundError:
        return f"ERROR: File '{file_path}' not found"
    except Exception as e:
        return f"ERROR: {str(e)}"


@tool
def write_cpp_file(file_path: str, cpp_code: str) -> str:
    """
    Write C++ code to a file.

    Args:
        file_path: Path for C++ file (e.g., 'src/Initialize.cpp')
        cpp_code: C++ code content
    """
    try:
        dir_path = os.path.dirname(file_path)
        if dir_path:
            os.makedirs(dir_path, exist_ok=True)
        with open(file_path, 'w') as f:
            f.write(cpp_code)
        return f"✓ C++ file written: {file_path}"
    except Exception as e:
        return f"ERROR: {str(e)}"


@tool
def update_makefile(makefile_path: str, cpp_files: str) -> str:
    """
    Create or update Makefile.

    Args:
        makefile_path: Path to Makefile
        cpp_files: Comma-separated C++ files (e.g., 'src/Initialize.cpp,src/main.cpp')
    """
    try:
        cpp_list = [f.strip() for f in cpp_files.split(',')]
        target = os.path.splitext(os.path.basename(cpp_list[0]))[0]

        makefile_content = f"""CXX = g++
CXXFLAGS = -std=c++11 -Wall

SRCS = {' '.join(cpp_list)}
TARGET = {target}

all: $(TARGET)

$(TARGET): $(SRCS)
\t$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRCS)

clean:
\trm -f $(TARGET)

.PHONY: all clean
"""
        with open(makefile_path, 'w') as f:
            f.write(makefile_content)
        return f"✓ Makefile updated: {makefile_path}"
    except Exception as e:
        return f"ERROR: {str(e)}"


@tool
def list_directory(path: str = ".") -> str:
    """
    List files in a directory.

    Args:
        path: Directory path (default: current directory)
    """
    try:
        items = os.listdir(path)
        dirs = [item for item in items if os.path.isdir(os.path.join(path, item))]
        files = [item for item in items if os.path.isfile(os.path.join(path, item))]

        output = f"Contents of '{path}':\n"
        if dirs:
            output += "\nDirectories:\n" + "".join(f"  📁 {d}/\n" for d in sorted(dirs))
        if files:
            output += "\nFiles:\n" + "".join(f"  📄 {f}\n" for f in sorted(files))
        return output
    except Exception as e:
        return f"ERROR: {str(e)}"


def create_agent():
    model = ArgoGPT5Mini()
    agent = CodeAgent(
        tools=[
            execute_code_scribe,
            run_build,
            read_source_file,
            write_cpp_file,      # Redundant with code-scribe translate 
            update_makefile,     # Redundant with code-scribe update 
            list_directory
        ],
        model=model,
        max_steps=20,
        verbosity_level=2
    )
    return agent


if __name__ == "__main__":
    agent = create_agent()

    translation_with_codescribe = """
    Translate src/Diffusion.F90 from Fortran to C++ using code-scribe:

    1. Run 'translate src/Diffusion.F90 -p prompts/code_translation.toml'
    2. Run 'update Makefile -p prompts/code_build.toml -r src/Diffusion.cpp -r src/Diffusion.hpp -r src/Diffusion_fi.F90'
    3. Run 'make' to build
    4. If build errors, analyze and fix the files without codescribe
    5. Repeat 3-4 build-fix cycle until success

    Be systematic and explain each step.
    """

    direct_agent_translation = """
    Translate src/Diffusion.F90 from Fortran to C++ and integrate into existing project:

    1. Read src/Diffusion.F90
    2. Translate Fortran MODULE/PROGRAM/SUBROUTINES to C++ functions/classes
    3. Write translated code to src/Diffusion.cpp (and src/Diffusion.h if needed)
    4. Update Makefile to compile all .cpp files: src/main.cpp, src/Diffusion.cpp, etc.
    5. Run 'make' to build single executable
    6. If build errors, analyze and fix C++ code, headers, or Makefile
    7. Repeat build-fix cycle until build succeeds

    Be systematic and explain each step.
    """

    task = translation_with_codescribe

    try:
        result = agent.run(task)
    except Exception as e:
        print(f"\nAgent error: {e}")
        import traceback
        traceback.print_exc()
