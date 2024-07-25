# Use the official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Add deadsnakes PPA and update the package list
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

# Install necessary packages
RUN apt-get install -y \
        git \
        git-lfs \
        wget \
        python3.10 \
        python3.10-venv \
        python3.10-distutils \
        python3-pip \
        libgl1 \
        libglib2.0-0 \
        && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Initialize Git LFS and clone the repository
RUN git lfs install && \
    git clone https://huggingface.co/wanderkid/PDF-Extract-Kit /opt/PDF-Extract-Kit

# Create a virtual environment for MinerU
RUN python3 -m venv /opt/mineru_venv

# Activate the virtual environment and install necessary Python packages
RUN /bin/bash -c "source /opt/mineru_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install magic-pdf[full-cpu] detectron2 --extra-index-url https://myhloli.github.io/wheels/"

# Copy the configuration file template and set up the model directory
COPY magic-pdf.template.json /root/magic-pdf.json

# Set the models directory in the configuration file
RUN sed -i 's|/opt/models|/opt/PDF-Extract-Kit/models|g' /root/magic-pdf.json

# Create the output directory
RUN mkdir -p /opt/output

# Set the entry point to activate the virtual environment and run the command line tool
ENTRYPOINT ["/bin/bash", "-c", "source /opt/mineru_venv/bin/activate && exec \"$@\"", "--"]
