;; css`...`
((call_expression
   function: (identifier) @_func
   arguments: (template_string (string_fragment) @injection.content))
  (#eq? @_func "css")
  (#set! injection.language "css"))
