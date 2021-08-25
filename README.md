# Managing Feature compatibility: a vendor comparison and analysis of its potential

This project contains supplementary material for the paper, "Eddy Truyen, Nane Kratzke, Dimitri Van Landuyt, Bert Lagaisse, Wouter Joosen, "Managing Feature compatibility in Kubernetes: Vendor comparison and Analysis"

The following sections provide technical background information about the goal of the paper, the data that has been collected for the case study, how that data has been collected, how it has been been processed and qualified and how the qualified data has been analyzed into the findings of the paper.

## Introduction
The Cloud Native Computing Foundation (CNCF) has launched a [certification programme](https://www.cncf.io/certification/software-conformance/#logos) for Kubernetes that includes more than a hundred vendors. The programme ensures a certain level of compatibility between vendors by enforcing that each vendor must meet a set of conformance tests. These conformance tests are a small subset of the [end-to-end (e2e) testing suite](https://github.com/kubernetes/kubernetes/tree/release-1.13/cluster/images/conformance) of the [open-source Kubernetes distribution](https://github.com/kubernetes/kubernetes/tree/release-1.13/test/e2e). 

As conformance tests constitute only a small part of the total e2e testing suite, we postulate that not all features of the open-source Kubernetes distribution are enforced by this certification programme. 

As such, we have explored feature incompatibilities between three major vendors of the hosted product type: Azure Kubernetes Service (AKS), AWS' Elastic Kubernetes Service (EKS) and Google Kubernetes Service (GKE). 
We have found that 30 out of 162 documented features of the open-source k8s release v1.13 are not supported by the default Kubernetes platform configuration of these vendors.

## Data 
We have consulted three sources of information for each vendor to detect and validate these feature incompatibilities:
* results of running relevant and applicable tests of the full end-to-end test suite
* inspecting relevant configuration files of running Kubernetes clustes
* inspecting relevant vendor documentation

The data is organized in a [feature mapping csv file](validation/mapping_of_e2e_tests_to_features.csv) that maps 162 k8s features, 66 feature gates and 28 admission controllers of k8s release v1.13 to the three sources of information. This accounts for a total of 256 mappings. An [extended Excel Sheet of this mapping file](mapping_of_e2e_tests_to_features.xlsx) contains explanations of what the admission controllers are about. Documentation of the other features can be found in Tables 2-10 and Table 28 of the [following technical report](https://arxiv.org/abs/2002.02806).

### End-to-end test results
The data of the tests results is organized as follows:

The [feature mapping csv file](validation/mapping_of_e2e_tests_to_features.csv) contains 233 mappings from k8s features to related tests of the e2e testing suite. All tests in this testing suite are labelled with String-based descriptors and each mapping refers to a subset of these labels to identify relevant tests. 

To process test results based on the feature mapping file, it is required that all relevant tests are beforehand executed upon the running Kubernetes clusters. We have simply executed all tests in different batches where each batch corresponds with all tests of a specific [package](https://github.com/kubernetes/kubernetes/tree/release-1.13/test/e2e) of the testing suite. Typically, each package is managed by a separate [k8s Special Interest Group](https://github.com/kubernetes/community/blob/master/sig-list.md) (K8s-SIG). We ran tests from different K8s-SIGs in separate batches to prevent interferences between tests due to residual effects.

We have used two tools for executing all tests from a k8s SIG upon a running  Kubernetes cluster. First, most tests are run using the [sonobuoy tool v14.3](https://sonobuoy.io/docs/v0.14.3/), which is the technology behind the conformance testing of the CNCF certification program. This tool can be easily [customized](https://sonobuoy.io/docs/v0.14.3/gen/) to execute all tests from a specific SIG group. 

However, the customization support of sonobuoy v14.3 is too limited for running tests for a specific cloud provider as required test parameters (e.g. cloud configuration files, credentials for connecting to the underlying cloud provider infrastructure services) cannot be passed to the e2e testing suite via this version of the tool. 
To deal with such cloud-provider-specific test cases, in accordance with the [advice of John Schnake](https://sonobuoy.io/custom-e2e-image/), we have built custom conformance container images for each cloud provider using the [open-source e2e conformance testing image of Kubernetes](https://github.com/kubernetes/kubernetes/tree/release-1.13/cluster/images/conformance) as base image. Github issues for how to customize the conformance image for [Azure AKS](https://github.com/vmware-tanzu/sonobuoy/issues/901) and [Google's GKE](https://github.com/vmware-tanzu/sonobuoy/issues/888) are provided. The approach for customizing towards AWS EKS is the same as for GKE.


We have tested various similar platform variants of the Kubernetes vendors:
* Standard cluster for Kubernetes release 1.11
* Custom cluster with support for network policies for Kubernetes release 1.11
* Standard cluster for Kubernetes release 1.13
* Custom cluster with support for network policies for Kubernetes release 1.13

We have run all e2e tests of all packages of the e2e testing suite for standard clusters, and only tests for network policies for custom clusters. 

All test data is available as a set of [tarballs](validation/results). The naming convention of the tarball is as follows:

```
PlatformVariantID[_provider]_E2ETestsID_TestingToolID-UniqueID.tar.gz
```
For example, `gke-1.13_sig-cluster-life-cycle_sonobuoy-74384u39.tar.gz` contains all test results of the *standard GKE cluster for Kubernetes release 1.13* from the *cluster-life-cycle e2e test package*  using the *sonobuoy tool*, whereas `gke-1.13-np_NetworkPolicies_sonobuoy-64289438.tar.gz` contains all test results of the *custom GKE cluster with support for network policies for Kubernetes release 1.13* for the *NetworkPolicy feature*  using the *sonobuoy tool*. 

The tarballs that are produced by the custom conformance container images for a specific cloud provider are labelled with the *_provider* string. E.g. `eks-1.13_provider_In-tree-Volumes_results.tar.gz` contains all test results of the "standard EKS cluster for k8s release 1.13*  for *In-tree volumes tests"  using a *custom conformance container image* with provider specific configurations for accessing the AWS infrastructure. 

The feature mapping file is automatically processed by a simple bash script to extract relevant test results for each of the 233 mappings. One first edits this script to set the `PROVIDERS`environment variable with a list of specific `PlatformVariantIDs` that one wishes to compare. More specifically, one has to edit the first line of the [validation/run.sh script](validation/run.sh):

```
cd validation
vi run.sh
```
For example setting this variable as follows:
```
export PROVIDERS="aks eks gke aks-1.13 eks-1.13 gke-1.13"
```
will compare the standard clusters of AKS, EKS and GKE for both Kubernetes release v1.11 and release v1.13.

To process the feature mapping file simply run the [run.sh script](validation/run.sh) from within the `validation` directory. This will create a folder `run-results` with a `Summary.csv`file that shows for each mapping the number of relevants tests and for each compared platform variant the number of succeeded and failed tests. Note that the sum of the succeeded and failed tests may be less than the number of relevant tests because some tests may be skipped because they are only meant for a specific cloud provider. By default, all cloud provider specific tests are skipped unless it concerns a tar ball with the `_provider` String. To get a better understanding about succeeded or failed tests, the `run-results` folder also contains structured records of the failed and succeeded tests. These records are organized in different sub-directories of the `run-results` directory in accordance with the above naming schemes of tarballs, i.e. each sub-directory's name matches the pattern `PlatformVariantID[_provider]_E2ETestsID_TestingToolID-UniqueID` and the contents of this subdirectory contains the complete logs and output of the using testing tool for the specific tests and platform variant.

A [synthesized Excel version of the Summary.csv file](validation/Summary.xlsx) contains the data for both standard clusters and custom clusters with network policies. 

### Configuration state
All collected configuration state for the three studied vendors can be found in the [configuration-state directory](validation/configuration-state). The most important files are two Word documents with prefix `k8-worker-containers-`. 
For each vendor, configuration proof for different platform variants, as presented in Table 5 of the paper, is appended in one Word file  for Kubernetes v1.11. Another Word file compares the basic platform variant between Kubernetes releases v1.11 and v1.13. The following table provides navigatable access to these Word files:

|  Vendor | Comparison of platform variants for v1.11  | Comparison of basic platform variants of v1.11 and v1.13 |
|---|---|---|
| AKS  | [link](validation/configuration-state/aks/k8-worker-containers-1.11.docx) | [link](validation/configuration-state/aks/k8-worker-containers-1.13.docx)  |
| EKS  | [link](validation/configuration-state/eks/k8-worker-containers-1.11.docx) | [link](validation/configuration-state/eks/k8-worker-containers-1.13.docx)  |
| GKE  | [link](validation/configuration-state/gke/k8-worker-containers-1.11.docx) | [link](validation/configuration-state/gke/k8-worker-containers-1.13.docx)  |

The relevant configuration state for release v1.13 is presented in the [feature mapping csv file](validation/mapping_of_e2e_tests_to_features.csv) as Configuration Proof, which is of type String. Configuration proof is either default configuration state according to the official Kubernetes documentation (e.g. information about the stability of a feature gate (alpha, beta, GA), or the specific parameter setting found in the worker nodes. For example, for the `PrivilegedPod feature`, configuration proof refers to the parameter setting `allow-privileged=TRUE`. This proof for this parameter setting can be found in the `k8-worker-containers-1.13.docx` document of each vendor. The most easy way to trace the proof is the use the `Find` menu of MS Word to search for the `allow-privileged=TRUE` String.

### Vendor documentation

Vendor documentation has been shown to be the most complete information source for the studied vendors. For each feature, the paper refers to relevant vendor documentation by means of bibliographic references. 

In the mapping file, for each feature, vendor documentation is grouped into a pair of two tuples. The first tuple groups the vendors in  classes with similar feature states. The second tuple lists the feature state for the different classes. Possible feature states are `TRUE`, `FALSE` or `Optional`. For example, `EKS/AKS GKE, Optional/False` implies that the feature can be optionally activated in EKS, and is not supported in AKS and GKE.  

When the value of all features states are of the Boolean type, then feature state of vendors always defaults to the negation of the second tuple. For example, `GKE,TRUE` implies that feature is enabled for GKE and for AKS and EKS the feature is not supported. 

## Analysis of data

The above data has been analyzed to provide findings for the paper as follows. 

### Summary sheet

The basic source of truth for the findings is listed in the [Summary.xlsx file](validation/Summary.xlsx). It is a (color)-annotated and synthesized version of the different `Summary.csv` files that have been generated by the `run.sh` script for the standard platform and custom platform with support for network policies. Each row corresponds with a specific mapping from a feature to vendor documentation, configuration state and a specific e2e test label that identified one or more test modules. 

The (color) legend is as follows:

1) Test modules
  * Green color: The test module contains matching tests for the feature and presents a valid test result
  * Orange color: The test module contains matching tests for the feature but does not present a valid test result. The mapping is appended with information why the result is not valid. One reason is that the test is skipped. Another reason is that the test produces a false negative; this reason is demarcated in the red color.
  * No color: The test is not a matching test for the feature, because it tests something else.
  * It() clause: A mapping can be annotated with an **It()** clause. The contents of the It() clause refers to the specific matching test and suggests that the mapping needs to be refined to map to this clause. 
2) Vendor documentation
  * Green color: There is an inconsistency between the vendor documentation and a valid test result
  * Bold font: A matching test produces invalid results, which are moreover inconsistent with the stated vendor documentation
  * (?,?) : There is no vendor documentation available
  
A [quantative analysis sheet for Table 8](QuantitativeAnalysisTable8.xlsx) allows to compute summarizing statistics, which are presented in the last row of Table 6. It also presents for each sub-aspect the number of features with matching tests, including those without valid test results but they can be potentially improved. These numbers allow thus to perform a cost-benefits analysis of improving existing test modules in order to achieve a better feature coverage. The main findings have been summarized in Section 3.10


### Analysis of vendor-agnostic reconfiguration and ease-of-migration
Table 9 of the paper presents in its bottom rows summarizing statistics for the studied vendors with respect to the analysis of the potential for vendor-agnostic feature compatibility management. These statistics are computed by following sheet:
A [quantative analysis sheet for Table 9](QuantitativeAnalysisTable9.xlsx) allows to answer questions about the number of feature incompatibilities that belong to a particular class of migration ease. These classses of migration ease can be distinguished by a simple scoring system that indicates the ease of migration from a source vendor to a target vendor: 
  * 5: For all subsets of features supported by the source vendor, automated migration is possible
  * 4: For all subsets of features supported by the source vendor, automated migration or vendor-agnostic reconfiguration is possible
  * 3: For all subsets of features supported by the source vendor, only vendor-agnostic reconfiguration is possible  
  * 2: For some subsets of features supported by the source vendor, automated migration or vendor agnostic reconfiguration is possible
  * 1: Only custom, vendor-specific translation of input/output data is possible for some subsets of features supported by the source vendor
  * 0: None of the feature subsets supported by the source vendor are supported by the target vendor 
  * –: None of the feature subsets of the sub-aspect are sup-ported by the source vendor

The last rows of Table 9 show then the number of occurences of scores with a particular range (e.g. The `number of scores <=2` indicate the number of difficult feature incompatibilities for which no complete vendor-agnostic approach exists, The `number of scores >=4` indicate the number of functional sub-aspects of the taxonomy where a few feature incompatibilities exist -- if any -- and these can all be bridged by means of a vendor-agnostic approach. The presented information allows to improve the state-of-the-art approaches for migrating or federating container platforms across cloud providers with better support for feature compatibility.


