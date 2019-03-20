
import hook_tools

hooks = [
    #'pre-commit',
    'prepare-commit-msg'
]

pre_commit_checks = [
    hook_tools.cpplint_check,
    hook_tools.jsonlint_check,
    hook_tools.cmakelint_check
]
