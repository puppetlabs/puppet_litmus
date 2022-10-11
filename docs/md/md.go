package md

import "embed"

//go:embed content/***
var DocsFS embed.FS

func GetDocsFS() embed.FS {
	return DocsFS
}
