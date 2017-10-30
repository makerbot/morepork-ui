
try:
    import artifactory_utils
except:
    pass
else:
    dependencies = [
        artifactory_utils.ArtifactSelector(
            project="Toolchain-Release",
            revision="develop",
            version="^4.6",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-build-root",
            revision="qt-5.9.2",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-mbcoreutils",
            revision="develop",
            version="^4.0",
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
