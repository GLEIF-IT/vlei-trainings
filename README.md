# vLEI Trainings

The official collection of GLEIF training materials for the vLEI ecosystem including both software developer focused trainings and executive focused trainings. Topics include wallet development, core protocol explanations, infrastructure deployment and usage, and threshold logic ranging across an increasing learning curve.

# Training Environment Setup

[Jupyter notebooks](https://jupyter.org/) are the primary format for developer-focused content while Markdown and associated PDFs are the primary format for executive-focused content.

To deploy the training environment, we use Docker to create a local instance of the vLEI ecosystem. This allows you to run the training materials in an isolated environment on your local machine.

## Prerequisites

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Docker](https://docs.docker.com/get-docker/)

## Setup and Deployment

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/GLEIF-IT/vlei-trainings.git
    cd vlei-trainings
    ```

2.  **Deploy the Environment:**
    Run the deployment script. This will build the necessary Docker images (can take a while the first time) and start all the containers in the background.
    ```bash
    ./deploy.sh
    ```

3. **Stop the environment:**
    If you need to stop the environment, run:
    ```bash
    ./stop.sh
    ```

## Accessing the Environment

1.  **Jupyter Lab:**
    a. Open your web browser and navigate to [http://localhost:8888](http://localhost:8888).
    b. In the JupyterLab IDE site, navigate in its file browser to the ```jupyter/notebooks``` directory, then open the ```000_Table_of_Contents.ipynb``` notebook. 

## Quick Context for LLMs: `llm_context.md`

Want to ask your favorite Large Language Model (LLM) questions about KERI, ACDC, or the vLEI ecosystem based on the content in this repository?

To help you get the most accurate and contextually relevant responses, we've compiled all the training material into a single, convenient file: **[`markdown/llm_context.md`](markdown/llm_context.md)**.

Simply upload `markdown/llm_context.md` as context to your LLM when you're asking questions about the topics covered here.

While this consolidated file is excellent for quick LLM lookups or generating summaries, we strongly encourage you to read and follow the original training material within this repository. The hands-on notebooks offer a step-by-step learning experience that is crucial for a deep understanding.

**⚠️ A Word of Caution:** Always critically evaluate responses from LLMs. While providing comprehensive context with `llm_context.md` can significantly improve accuracy, LLMs may still generate incorrect or misleading information.

## Report issues and Feedback
We welcome your feedback to improve these training materials!

If you find any errors, typos, or areas that could be clearer, or if you have suggestions for new content or improvements, please let us know. The way to do this is by creating an issue on our GitHub repository.

How to report an issue or provide feedback:
- Go to the Issues tab of the vlei-trainings repository **[(or click here)](https://github.com/GLEIF-IT/vlei-trainings/issues)**.
- Click on the "New issue" button.
- Provide a descriptive title and a clear explanation of the issue or your feedback. If you are reporting a bug, please include steps to reproduce - it if possible.
- Submit the issue.

We appreciate your help in making these training materials as accurate and effective as possible!

### Authors
- GLEIF vLEI Development Team

