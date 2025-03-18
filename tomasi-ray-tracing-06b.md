# CI builds {#ci-builds}

# CI builds

-   When managing *pull requests*, it is necessary to be sure that the change does not worsen the code.

-   A basic requirement is that all tests continue to pass once the *pull request* is merged.

-   GitHub allows you to automatically verify this requirement, using *Continuous Integration builds* (which GitHub calls *GitHub actions*).

# Continuous Integration (CI)

-   It is a term that indicates a working method in which improvements and code changes are incorporated as soon as possible into the `master` branch.

-   Before they can be incorporated, it is necessary to be certain of their quality!

-   A CI build consists of creating a virtual machine on which a «clean» operating system is installed and on which the code is installed, compiled, and the tests are run.

-   At the end of the test execution, the virtual machine is deleted; if the CI build is run again, it starts over.

# Advantages of CI builds

-   They install the code on a virtual machine: it's harder to mess things up.

-   The virtual machine is always created from scratch: it's easier to discover the code's dependencies. (Example: which version of the C++ compiler was installed? Was the `libgd` library installed?)

-   You can create multiple virtual machines with different operating systems (Linux, Windows, Mac OS X…): the code is verified on each of them.

-   CI builds can be run automatically by GitHub every time a pull request is opened, every time a commit is made, etc.

# CI builds in GitHub

-   A CI build can be created and executed in GitHub using [GitHub Actions](https://docs.github.com/en/actions), a service that includes several possibilities that go beyond simple CI builds.

-   To activate a CI build, it is sufficient to create a hidden directory `.github/workflows` in your repository, containing a text file in [YAML](https://en.wikipedia.org/wiki/YAML) format, which contains this information:

    #.   When to execute the action (on every pull request? on every commit?)
    #.   Which operating system to use (Linux? Windows? which version?)
    #.   Which additional packages to install (C++ compiler? Python?)
    #.   How to compile the code and run the tests?

# The «Marketplace»

-   GitHub Actions has a «marketplace» that allows you to automatically configure a CI build with a few mouse clicks, depending on the language you use.

-   Pre-configured actions are available for many languages and development environments.

-   It's not a problem if you don't find an action that suits your needs: it's quite simple to create new custom actions, once you understand how to describe them.

---

<center>
![](./media/github-action-run-tests.png){height=720px}
</center>

---

<center>
![](./media/github-action-run-tests-detail.png){height=720px}
</center>


# What can be done in a CI build?

-   You can run *linters* like [PyFlakes](https://pypi.org/project/pyflakes/) for Python or [CSA](https://clang-analyzer.llvm.org/) for C++.

-   If you use an automatic formatting tool (like [black](https://github.com/psf/black) for Python or [clang-format](https://clang.llvm.org/docs/ClangFormat.html) for C++), you can verify that the code is formatted correctly.

-   You can use sites like [ReadTheDocs](https://about.readthedocs.com/?ref=readthedocs.org) to publish the user manual with [Sphinx](https://www.sphinx-doc.org/), [MkDocs](https://www.mkdocs.org/) or [Jupyter Book](https://jupyterbook.org/en/stable/intro.html), ensuring that updated *docstrings* are included.

-   You can generate ready-to-download executables: this way the user is not obliged to install a C++/Nim/Rust/… compiler.

-   **The only requirement for this course is that you run the tests!**


# What to do today

# What to do today

-   Add a *workflow* to your GitHub repository.

-   There are many templates available in GitHub: choose the most appropriate one.

-   The workflow must perform the following actions:

    1.  Download the code from the GitHub repository (verify that no files are missing);
    2.  Compile the code (verify that there are no syntax errors);
    3.  Run the tests (verify that the code works properly).

-   Modify a test so that it fails and verify that when you commit this is reported to you. (Then fix the test).

# Hints for C++

# GitHub Actions

- Once you have saved the code in a GitHub repository, set up a new "Action" (see the following video).

- The template is "CMake based projects" (ignore the fact that it seems to only support the C language):

    <center>
    ![](./media/cmake-github-action.png)
    </center>

---

<iframe src="https://player.vimeo.com/video/520878087?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" width="1280" height="720" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen title="Setting up GitHub Actions for CMake-based projects"></iframe>

# Hints for Java/Kotlin

# GitHub Actions

-   Whether you use Java or Kotlin, select «Java with Gradle»:

    <center>
    ![](./media/gradle-github-action.png)
    </center>

    If you use Kotlin, Gradle will automatically download what is needed to support it.

-   The process will try to compile the code and run *all* the tests in the repository

# Troubleshooting

-   Remember to add the files in `gradle/wrapper/` to the commit

-   If you have problems in Kotlin due to the Gradle version, regenerate `gradlew` from the command line like this:

    ```sh
    gradle wrapper --gradle-version 8.4
    ```

    (Keep in mind that Gradle supports Kotlin only starting from version 5.3).

# Hints for C\#

# GitHub Actions

-   Add an Action to the GitHub repository, once you have committed and executed `git push`.

-   The template is «.NET» (avoid the «.NET desktop» template, we need the one for programs that work from the command line):

    <center>
    ![](./media/dotnet-github-action.png)
    </center>

# Hints for D/Nim/Rust

# GitHub Actions

-   For D, you can use [setup-dlang](https://github.com/dlang-community/setup-dlang)

-   For Nim, there is [Setup Nim Environment](https://github.com/marketplace/actions/setup-nim-environment)

-   Those using Rust have already configured an action, so everything is ok!

---
title: "Laboratory 6"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
