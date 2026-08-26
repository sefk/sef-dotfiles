-- Markdown: nvim edits plain text, glow renders it.
--
-- This file used to carry four plugins (render-markdown.nvim,
-- markdown-table-wrap.nvim, table-nvim, markdown-preview.nvim) that all painted
-- extmarks, virtual text, or virtual lines over the buffer. Over a remote stack
-- (ssh/mosh -> herdr -> nvim) that produced garbled screens and duplicated
-- lines: concealment and virtual lines change the byte<->column mapping, so any
-- dropped or reordered cell update leaves stale glyphs behind. Nothing here
-- renders markdown in-buffer any more -- <leader>mp shells out to glow instead.
return {}
