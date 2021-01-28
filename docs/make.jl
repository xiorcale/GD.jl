using Documenter, DocumenterLaTeX
using GD

makedocs(
    sitename = "GD",
    authors = "xiorcale",
    # format = DocumenterLaTeX.LaTeX(),
    pages = [
        "GD" => "index.md",
        "Storage" => "storage.md",
        "Transform" => "transform.md"
    ]
)