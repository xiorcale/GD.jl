using Documenter, DocumenterLaTeX
using GD

makedocs(
    sitename = "GD.jl",
    authors = "xiorcale",
    # format = DocumenterLaTeX.LaTeX(),
    pages = [
        "Home" => "index.md",
        "Storage" => "storage.md",
        "Transform" => "transform.md"
    ]
)