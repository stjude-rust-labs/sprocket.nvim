# Release Process

1. Update the `CHANGELOG.md` with the new date and add a new `## Unreleased` section.
2. Commit with the message `release: bumps the version to vX.Y.Z`.
3. Tag the commit: `git tag vX.Y.Z && git push --tags`.
4. Create a GitHub release for the tag and copy the notes from `CHANGELOG.md`.
