
try:
    import artifactory_utils
except:
    pass
else:
    dependencies = [
        artifactory_utils.ArtifactSelector(
            project="Toolchain-Release",
            revision="ReleaseMorepork1.12",
            version="^4.6",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-build-root",
            revision="ReleaseMorepork1.12",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-mbcoreutils",
            revision="ReleaseMorepork1.12",
            version="^4.0",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-json-cpp",
            revision="ReleaseMorepork1.12",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-jsonrpc",
            revision="ReleaseMorepork1.12",
            debug=False,
            stable_required=True),
        artifactory_utils.ArtifactSelector(
            project="morepork-libtinything",
            revision="ReleaseMorepork1.12",
            debug=False,
            stable_required=True),
    ]
