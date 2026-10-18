# Reusable Workflows for GitHub Actions

A collection of reusable workflows and composite actions for GitHub Actions.

## Reusable Workflows

All workflows are triggered via `workflow_call` and pin actions to full commit SHAs.
Checkout steps use `persist-credentials: false` to prevent token persistence in the git config.

### Usage

```yaml
jobs:
  lint:
    uses: <owner>/<repo>/.github/workflows/actionlint.yml@main
```

### Workflows

| Workflow                | Description                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------------- |
| `actionlint.yml`        | Lint GitHub Actions workflow files using [actionlint](https://github.com/rhysd/actionlint)  |
| `codeql.yml`            | Run GitHub CodeQL analysis for one or more languages                                        |
| `dependency-review.yml` | Review dependency changes for known vulnerabilities                                         |
| `devskim.yml`           | Run [DevSkim](https://github.com/microsoft/DevSkim) security analysis                       |
| `markdownlint.yml`      | Lint Markdown files using [markdownlint](https://github.com/igorshubovych/markdownlint-cli) |
| `yamllint.yml`          | Lint YAML files using [yamllint](https://github.com/adrienverge/yamllint)                   |

### Permissions

| Workflow                | Permissions                                                 | Rationale                                                     |
| ----------------------- | ----------------------------------------------------------- | ------------------------------------------------------------- |
| `actionlint.yml`        | `contents: read`                                            | Checkout repository                                           |
| `codeql.yml`            | `actions: read`, `contents: read`, `security-events: write` | Checkout repository, read workflow info, upload SARIF results |
| `dependency-review.yml` | `contents: read`                                            | Checkout repository                                           |
| `devskim.yml`           | `actions: read`, `contents: read`, `security-events: write` | Checkout repository, read workflow info, upload SARIF results |
| `markdownlint.yml`      | `contents: read`                                            | Checkout repository                                           |
| `yamllint.yml`          | `contents: read`                                            | Checkout repository                                           |

## Composite Actions

### `actions/gitleaks`

Run [gitleaks](https://github.com/gitleaks/gitleaks) to detect secrets in your repository.

| Required caller permissions | Rationale                     |
| --------------------------- | ----------------------------- |
| `contents: read`            | Checkout and scan git history |

### `actions/random-number`

Generate a random number. No permissions required.

### `actions/release`

Create a GitHub release using the `gh` CLI.

| Required caller permissions | Rationale                         |
| --------------------------- | --------------------------------- |
| `contents: write`           | Create releases and upload assets |

## License

This project is licensed under the [MIT License](LICENSE).
