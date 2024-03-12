# Maintenance

- Perform an interactive and assisted upgrade using `make upgrade`.
- Review all "Containerfile" image references.
- Review the below...

## NodeJS projects

Check ".node-version" against the current NodeJS LTS version.

The "packageManager" entry for "packages.json" should usually be set to the latest release of the specific package manager being used by the project.

Generally, the "engines" section of "packages.json" should be set to:

- "node" should be greater than or equal to the current Long-Term Support (LTS) version to ensure all machines are using LTS or later and less than the next major version beyond the current LTS version to ensure that LTS minor upgrades and patches are automatically included until the version can be bumped. The version range should not include "Current" releases that are not yet under LTS.
- "npm" should be greater than or equal to the version shipped with the most recent Long-Term Support (LTS) version specified in the "node" version range. This allows the primary "node" depenendency to be upgraded to include any version of "npm" greater than the version specified.
- "yarn" should be greater than or equal to the version shipped with the most recent Long-Term Support (LTS) version in the most recent "node" OCI container image. While "node" is dependent on NodeJS releases and "npm" is dependent on bundling with "node", the "yarn" version specifically depends on the container release.

### Example

```json
{
  "engines": {
    /*
      A version range where the lower version is the most recent LST version
      relative to the last time project maintainers checked it. The second
      version would be the next major upgrade to allow the LTS version to
      automatically be included when minor upgrades and patches are released.
    */
    "node": ">=20.11.1 <21.0.0",
    /*
      This is the version shipped inside of the most recent OCI container
      image associated with the LTS version of "node" above.
    */
    "npm": ">=10.4.0",
    /*
      This is the version shipped inside of the most recent OCI container
      image associated with the LTS version of "node" above.
    */
    "yarn": ">=1.22.19"
  }
}
```
