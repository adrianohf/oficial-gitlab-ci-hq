---
stage: Secure
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
type: reference
---

# Secure and Govern terminology **(FREE)**

The glossary of terms aims to achieve the following:

- Promote a ubiquitous language that can be used everywhere - with customers, on issues, in Slack, in code.
- Improve the effectiveness of communication between team members.
- Reduce the potential for miscommunication.
- Bring new team members and community contributors up to speed faster, reducing the time to productivity.

The definitions of the terms outlined in this document are in the context of the GitLab
products. Therefore, a term may have a different meaning to users outside of GitLab.

## Terms

### Analyzer

Software that performs a scan. The scan analyzes an attack surface for vulnerabilities and produces
a report containing findings. Reports adhere to the [Secure report format](#secure-report-format).

Analyzers integrate into GitLab using a CI job. The report produced by the analyzer is published as
an artifact after the job is complete. GitLab ingests this report, allowing users to visualize and
manage found vulnerabilities. For more information, see [Security Scanner Integration](../../../development/integrations/secure.md).

Many GitLab analyzers follow a standard approach using Docker to run a wrapped scanner. For example,
the image `semgrep` is an analyzer that wraps the scanner `Semgrep`.

### Attack surface

The different places in an application that are vulnerable to attack. Secure products discover and
search the attack surface during scans. Each product defines the attack surface differently. For
example, SAST uses files and line numbers, and DAST uses URLs.

### Corpus

The set of meaningful test cases that are generated while the fuzzer is running. Each meaningful
test case produces new coverage in the tested program. It's advised to re-use the corpus and pass it
to subsequent runs.

### CNA

[CVE](#cve) Numbering Authorities (CNAs) are organizations from around the world that are authorized by
the [Mitre Corporation](https://cve.mitre.org/) to assign [CVE](#cve)s to vulnerabilities in products or
services within their respective scope. [GitLab is a CNA](https://about.gitlab.com/security/cve/).

### CVE

Common Vulnerabilities and Exposures (CVE®) is a list of common identifiers for publicly known
cybersecurity vulnerabilities. The list is managed by the [Mitre Corporation](https://cve.mitre.org/).

### CVSS

The Common Vulnerability Scoring System (CVSS) is a free and open industry standard for assessing
the severity of computer system security vulnerabilities.

### CWE

Common Weakness Enumeration (CWE™) is a community-developed list of common software and hardware
weakness types that have security ramifications. Weaknesses are flaws, faults, bugs,
vulnerabilities, or other errors in software or hardware implementation, code, design, or
architecture. If left unaddressed, weaknesses could result in systems, networks, or hardware being
vulnerable to attack. The CWE List and associated classification taxonomy serve as a language that
you can use to identify and describe these weaknesses in terms of CWEs.

### Deduplication

When a category's process deems findings to be the same, or if they are similar enough that a noise reduction is
required, only one finding is kept and the others are eliminated. Read more about the [deduplication process](../vulnerability_report/pipeline.md#deduplication-process).

### Duplicate finding

A legitimate finding that is reported multiple times. This can occur when different scanners
discover the same finding, or when a single scan inadvertently reports the same finding more than
once.

### False positive

A finding that doesn't exist but is incorrectly reported as existing.

### Feedback

Feedback the user provides about a finding. Types of feedback include dismissal, creating an issue,
or creating a merge request.

### Finding

An asset that has the potential to be vulnerable, identified in a project by an analyzer. Assets
include but are not restricted to source code, binary packages, containers, dependencies, networks,
applications, and infrastructure.

Findings are all potential vulnerability items scanners identify in MRs/feature branches. Only after merging to default does a finding become a [vulnerability](#vulnerability).

### Grouping

A flexible and non-destructive way to visually organize vulnerabilities in groups when there are multiple findings
that are likely related but do not qualify for deduplication. For example, you can include findings that should be
evaluated together, would be fixed by the same action, or come from the same source. Grouping behavior for vulnerabilities is
under development and tracked in issue [267588](https://gitlab.com/gitlab-org/gitlab/-/issues/267588).

### Insignificant finding

A legitimate finding that a particular customer doesn't care about.

### Location fingerprint

A finding's location fingerprint is a text value that's unique for each location on the attack
surface. Each security product defines this according to its type of attack surface. For example, SAST
incorporates file path and line number.

### Package managers and package types

#### Package managers

A package manager is a system that manages your project dependencies.

The package manager provides a method to install new dependencies (also referred to as "packages"), manage where packages are stored on your file system, and offer capabilities for you to publish your own packages.

#### Package types

Each package manager, platform, type, or ecosystem has its own conventions and protocols to identify, locate, and provision software packages.

The following table is a non-exhaustive list of some of the package managers and types referenced in GitLab documentation and software tools.

<style>
table.package-managers-and-types tr:nth-child(even) {
    background-color: transparent;
}

table.package-managers-and-types td {
    border-left: 1px solid #dbdbdb;
    border-right: 1px solid #dbdbdb;
    border-bottom: 1px solid #dbdbdb;
}

table.package-managers-and-types tr td:first-child {
    border-left: 0;
}

table.package-managers-and-types tr td:last-child {
    border-right: 0;
}

table.package-managers-and-types ul {
    font-size: 1em;
    list-style-type: none;
    padding-left: 0px;
    margin-bottom: 0px;
}
</style>

<table class="package-managers-and-types">
  <thead>
    <tr>
      <th>Package Type</th>
      <th>Package Manager</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>gem</td>
      <td><a href="https://bundler.io/">bundler</a></td>
    </tr>
    <tr>
      <td>packagist</td>
      <td><a href="https://getcomposer.org/">composer</a></td>
    </tr>
    <tr>
      <td>conan</td>
      <td><a href="https://conan.io/">conan</a></td>
    </tr>
    <tr>
      <td>go</td>
      <td><a href="https://go.dev/blog/using-go-modules">go</a></td>
    </tr>
    <tr>
      <td rowspan="3">maven</td>
      <td><a href="https://gradle.org/">gradle</a></td>
    </tr>
    <tr>
      <td><a href="https://maven.apache.org/">maven</a></td>
    </tr>
    <tr>
      <td><a href="https://www.scala-sbt.org">sbt</a></td>
    </tr>
    <tr>
      <td rowspan="2">npm</td>
      <td><a href="https://www.npmjs.com">npm</a></td>
    </tr>
    <tr>
      <td><a href="https://classic.yarnpkg.com/en">yarn</a></td>
    </tr>
    <tr>
      <td>nuget</td>
      <td><a href="https://www.nuget.org/">nuget</a></td>
    </tr>
    <tr>
      <td rowspan="4">pypi</td>
      <td><a href="https://setuptools.pypa.io/en/latest/">setuptools</a></td>
    </tr>
    <tr>
      <td><a href="https://pip.pypa.io/en/stable">pip</a></td>
    </tr>
    <tr>
      <td><a href="https://pipenv.pypa.io/en/latest">Pipenv</a></td>
    </tr>
    <tr>
      <td><a href="https://python-poetry.org/">Poetry</a></td>
    </tr>
  </tbody>
</table>

### Pipeline Security tab

A page that displays findings discovered in the associated CI pipeline.

### Post-filter

Post-filters help reduce noise in the scanner results and automate manual tasks. You can specify criteria that updates
or modifies vulnerability data based on scanner results. For example, you can flag findings as likely False Positives
and automatically resolve vulnerabilities that are no longer detected. These are not permanent actions and can be changed.

Support for automatically resolving findings is tracked in epic [7478](https://gitlab.com/groups/gitlab-org/-/epics/7478) and
support for cheap scan is proposed in issue [349926](https://gitlab.com/gitlab-org/gitlab/-/issues/349926).

### Pre-filter

An irreversible action that is done to filter out targets before analysis occurs. This is usually provided to allow
the user to reduce scope and noise as well as speed up the analysis. This should not be done if a record is needed as
we currently do not store anything related to the skipped/excluded code or assets.

Examples: `DS_EXCLUDED_PATHS` should `Exclude files and directories from the scan based on the paths provided.`

### Primary identifier

A finding's primary identifier is a value that is unique to each finding. The external type and external ID
of the finding's [first identifier](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/v2.4.0-rc1/dist/sast-report-format.json#L228)
combine to create the value.

Examples of primary identifiers include `PluginID` for OWASP Zed Attack Proxy (ZAP), or `CVE` for
Trivy. Note that the identifier must be stable. Subsequent scans must return the same value for the
same finding, even if the location has slightly changed.

### Report finding

A [finding](#finding) that only exists in a report produced by an analyzer, and is yet to be
persisted to the database. The report finding becomes a [vulnerability finding](#vulnerability-finding)
once it's imported into the database.

### Scan type (report type)

Describes the type of scan. This must be one of the following:

- `api_fuzzing`
- `cluster_image_scanning`
- `container_scanning`
- `coverage_fuzzing`
- `dast`
- `dependency_scanning`
- `sast`
- `secret_detection`

This list is subject to change as scanners are added.

### Scanner

Software that can scan for vulnerabilities. The resulting scan report is typically not in the
[Secure report format](#secure-report-format). Examples include ESLint, Trivy, and ZAP.

### Secure product

A group of features related to a specific area of application security with first-class support by
GitLab.

Products include Container Scanning, Dependency Scanning, Dynamic Application Security
Testing (DAST), Secret Detection, Static Application Security Testing (SAST), and Fuzz Testing.

Each of these products typically include one or more analyzers.

### Secure report format

A standard report format that Secure products comply with when creating JSON reports. The format is described by a
[JSON schema](https://gitlab.com/gitlab-org/security-products/security-report-schemas).

### Security Dashboard

Provides an overview of all the vulnerabilities for a project, group, or GitLab instance.
Vulnerabilities are only created from findings discovered on the project's default branch.

### Seed corpus

The set of test cases given as initial input to the fuzz target. This usually speeds up the fuzz
target substantially. This can be either manually created test cases or auto-generated with the fuzz
target itself from previous runs.

### Vendor

The party maintaining an analyzer. As such, a vendor is responsible for integrating a scanner into
GitLab and keeping it compatible as they evolve. A vendor isn't necessarily the author or maintainer
of the scanner, as in the case of using an open core or OSS project as a base solution of an
offering. For scanners included as part of a GitLab distribution or GitLab subscription, the vendor
is listed as GitLab.

### Vulnerability

A flaw that has a negative impact on the security of its environment. Vulnerabilities describe the
error or weakness, and don't describe where the error is located (see [finding](#finding)).

Each vulnerability maps to a unique finding.

Vulnerabilities exist in the default branch. Findings (see [finding](#finding)) are all potential vulnerability items scanners identify in MRs/feature branches. Only after merging to default does a finding become a vulnerability.

### Vulnerability finding

When a [report finding](#report-finding) is stored to the database, it becomes a vulnerability
[finding](#finding).

### Vulnerability tracking

Deals with the responsibility of matching findings across scans so that a finding's life cycle can
be understood. Engineers and security teams use this information to decide whether to merge code
changes, and to see unresolved findings and when they were introduced.

Vulnerabilities are tracked by comparing the location fingerprint, primary identifier, and report type.

### Vulnerability occurrence

Deprecated, see [finding](#finding).
