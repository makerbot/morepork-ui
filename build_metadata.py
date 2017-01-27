
try:
    import artifactory_utils
except:
    pass
else:
    dependencies = [
        artifactory_utils.ArtifactSelector(
            project="Toolchain-Release",
            revision="develop",
            version="4.*",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-build-root",
            revision="develop",
            version="*",
            debug=False,
            stable_required=True),
    ]
