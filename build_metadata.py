
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
            revision="morepork",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-mbcoreutils",
            revision="develop",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-json-cpp",
            revision="develop",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-jsonrpc",
            revision="develop",
            debug=False,
            stable_required=True),
    ]
