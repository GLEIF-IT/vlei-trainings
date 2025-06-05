# Welcome to vLEI Training - 101

This collection of Notebooks is designed to guide you through the foundational concepts of the [Key Event Receipt Infrastructure](https://trustoverip.github.io/tswg-keri-specification/) (KERI) and [Authentic Chained Data Containers](https://trustoverip.github.io/tswg-acdc-specification/) (ACDC) protocols, followed by the workings of the [verifiable Legal Entity Identifier](https://www.gleif.org/en/organizational-identity/introducing-the-verifiable-lei-vlei/introducing-the-vlei-ecosystem-governance-framework) (vLEI) ecosystem. We aim to equip you with the knowledge needed to build applications leveraging this powerful identity technology.

After completing this training, you will:
- Understand the KERI protocol
- Understand the ACDC protocol
- Understand the vLEI ecosystem
- Have the basis to develop your own vLEI POC


## Prerequisites

The training aims to be accessible, but having background knowledge will certainly smooth your learning journey.

1.  **Command-Line Interface (CLI) Familiarity:** The training will involve using the KERI Command Line Interface (KLI). Therefore, having prior experience working with a terminal or command prompt (like Bash, Zsh, PowerShell, or Windows CMD) is highly beneficial. 

2.  **Conceptual Understanding of Digital Identity:** A general awareness of digital identity concepts and some understanding of the limitations of traditional systems will provide useful context for understanding KERI's purpose.

3.  **Basic Cryptography Concepts:** Having a basic understanding of what public and private keys are and the general idea behind digital signatures and hash functions will give you a head start.

4.  **Python Programming:** The training includes several Python scripts.

5.  **TypeScript Programming:** Code snippets from the 102 module notebooks utilize TypeScript code. 

6.  **Docker Basics:** For setting up and troubleshooting more complex KERI environments or running components like witnesses or agents, a basic understanding of Docker concepts (containers, images, `docker-compose`) will be useful.

## Understanding Your Learning Environment

This training series utilizes Jupyter Notebooks to provide an interactive and hands-on learning experience. Jupyter Notebooks allow for a mix of explanatory text, and live, executable code cells, creating a dynamic way to understand complex topics like KERI, ACDCs, and the vLEI ecosystem.

### Notebook Philosophy

Each notebook in this series is designed to be largely **stand-alone for the concepts it introduces**, building upon the knowledge from previous notebooks. While conceptual links are strong, the code examples within a specific notebook are generally self-contained or rely on a clearly defined setup at the beginning of that notebook.

Crucially, **cells within a single notebook are meant to be executed in sequence from top to bottom.** Variables, states, and environments created in earlier cells are often prerequisites for later cells to function correctly. Running cells out of order, or skipping cells, will likely lead to errors or unexpected behavior.

### Navigating Large Notebooks

For longer notebooks, navigating can be made easier using the **Table of Contents (ToC)** feature. In Jupyter Lab, you can find this in the left sidebar.
* Look for an icon that resembles a list or a document outline. Clicking this will open a navigable ToC based on the Markdown headings (H1, H2, H3, etc.) in the notebook.
* This allows you to quickly jump to specific sections of the notebook, which is especially helpful when reviewing material or looking for particular topics.

### Interacting with Notebook Cells

Jupyter Notebooks are composed of different types of cells, primarily:

* **Markdown Cells:** These cells contain explanatory text, like the one you are reading now. They are formatted using Markdown syntax, which allows for rich text formatting, images, and links. You do not "run" Markdown cells in the same way as code cells, but they are rendered to display the formatted text.
* **Code Cells:** These cells contain executable code. In this training series, you will encounter:
    * Shell commands (for `kli`): Prefixed with an exclamation mark (`!`), e.g., `!kli status`.
    * Python code: For scripting, examples, and utility functions.
    * TypeScript code: In the 102 module notebooks for `signify-ts` examples.

**Running Code Cells:**
To execute a code cell:
1.  Select the cell by clicking on it.
2.  Press `Shift + Enter` to run the current cell and automatically select the next cell.
3.  Alternatively, you can click the "Run" button (a play icon ▶️) in the toolbar.

When a code cell is running, an asterisk (`[*]`) will appear in the brackets to its left. Once execution is complete, a number (e.g., `[1]`) will replace the asterisk, indicating the order of execution. Any output from the code (text, errors, etc.) will be displayed directly below the cell.

**Running All Cells:**
If you want to run all cells in a notebook from top to bottom, especially after restarting the kernel or opening the notebook fresh, you can use the "Restart Kernel and Run All Cells" option.
* In Jupyter Lab, this is found in the "Kernel" menu (`Kernel > Restart Kernel and Run All Cells...`) or as a button in the toolbar (represented by a double play icon ⏩).
* This is a convenient way to ensure the entire notebook is executed in the correct order.

<div class="alert alert-info">
<b>💡 TIP</b><hr>
If you see `In [*]:` next to a cell for a long time, it means the code is still running. Some operations, especially those involving network communication or complex cryptographic processes, might take a few moments to complete.
</div>

### Managing the Notebook Kernel

Each active notebook is connected to a "kernel," which is the computational engine that executes the code in the notebook's cells.

* **Restarting the Kernel:** If you encounter persistent errors, or if you want to reset the notebook's state and start fresh (e.g., clear all variables), you can restart the kernel.
    * In Jupyter Lab, this is done via the "Kernel" menu: `Kernel > Restart Kernel...`.
    * Restarting the kernel will require you to re-run cells from the beginning to redefine variables and recreate the necessary state (or use "Restart Kernel and Run All Cells").
* **Interrupting the Kernel:** If a cell is taking too long to execute or you suspect it's stuck in an infinite loop, you can interrupt the kernel.
    * In Jupyter Lab, use `Kernel > Interrupt Kernel`.
    * You can also use the **Stop button** (A square ⏹️ icon) in the toolbar to interrupt the currently running cell.

### Clearing Output

You can clear the output of a single cell or all cells in a notebook:
* **Current Cell:** `Edit > Clear Output` (or right-click the cell).
* **All Cells:** `Edit > Clear All Outputs`.

This can be useful for decluttering the view or before re-running a notebook from scratch.


## Software Versions

This material was created and tested to work with:

- **[weboftrust/keri:1.2.6](https://github.com/WebOfTrust/keripy/releases/tag/1.2.6)**
- **[gleif/keria:0.3.0](https://github.com/GLEIF-IT/keria/releases/tag/0.3.0)**
- **[weboftrust/signify-ts:0.3.0-rc1](https://www.npmjs.com/package/signify-ts)**
- **[weboftrust/vlei:1.0.0](https://github.com/WebOfTrust/vLEI/releases/tag/1.0.0)**

<div class="alert alert-info">
  <b>🧩 DID YOU KNOW?</b><hr>
KERI, ACDC, and the vLEI ecosystem offer a strong foundation for secure digital interactions. However, achieving truly strong security requires additional effort. Real-world safety depends on proper implementation and security practices. Even the best technology can be weakened by things like losing control of private keys, or people being tricked into giving away their access (social engineering). Achieving real security is about combining strong technology with sound operational security measures.
</div>







[<- Prev (TOC)](000_Table_of_Contents.ipynb) | [Next (Intro) ->](101_07_Introduction_to-KERI_ACDC_and_vLEI.ipynb)
