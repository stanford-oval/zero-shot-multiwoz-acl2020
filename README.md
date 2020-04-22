# Zero-Shot Transfer Learning with Synthesized Data for Multi-Domain Dialogue State Tracking

This repository is the artifact associated with our paper, which was published in ACL 2020.

You can use this repository to reproduce our experiments exactly.
If you use any of the software in this repository, please cite:

```bibtex
@inproceedings{
...
}
```

## Setup

To reproduce our papers, you need the following repositories, and their exact version:

- <https://github.com/stanford-oval/trade-dst> tag acl2020-submission (d2326a446f07124d2d5babe676fef54dd1b04491)
- <https://github.com/stanford-oval/genie-toolkit> tag acl2020-submission (d37d0c01735d14c32fd699e358405e22b9cf51be)

You will also need the following packages:
- nodejs (version 10.*)
- yarn
- python3 (>=3.6)
- git
- a working c++ compiler
- make
- gettext
- unzip

To install the dependencies for genie-toolkit, run the following inside the genie-toolkit clone:
```
yarn install
```

To install the dependencies for trade-dst, run the following inside the trade-dst clone:
```
pip3 install -r requirements.txt
```

NOTE: the trade-dst repository includes the scripts and Dockerfiles that we used to run on Kubernetes. These scripts might be useful, if you have a Kubernetes cluster on AWS. The documentation for these scripts is provided at <https://github.com/stanford-oval/genie-k8s>.

## Pretrained Models

Pretrained models can be downloaded from...

## Evaluating The Trained Models

### Figure 1

### Figure 2

## Generating New Fresh Datasets

## Training
