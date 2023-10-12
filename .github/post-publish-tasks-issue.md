---
title: Post publish tasks
labels: release management 
---
These are the steps / tasks to perform:

## Script

1. Run **build/postPublishTasks.ps1** to generate and save documentation to the correct directories.
2. Copy generated documentation to techspace.
3. Fix formatting and language specification for code blocks.

## Manually

1. Save new version of module to projectRoot/publishedModules/version.
2. Generate documentation with [New-MarkdownHelp](https://learn.microsoft.com/en-us/powershell/module/platyps/new-markdownhelp) to projectRoot/docs/version.
3. Sort generated documentation into a public and private folder in projectRoot/docs/version.
4. Copy generated documentation to techspace.
5. Fix formatting and language specification for code blocks.
