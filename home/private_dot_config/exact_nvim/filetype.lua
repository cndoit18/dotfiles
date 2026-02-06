vim.filetype.add({
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.tmpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		[".*/templates/.*%.txt"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml.gotmpl"] = "helm",
		-- ["values.*%.yaml"] = "yaml.helm-values",
	},
	extension = {
		gotmpl = "gotmpl",
	},
})
