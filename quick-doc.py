#!/usr/bin/python
import re

INPUT = "common.sh"
INPUT_README = "README-nodoc.md"
OUTPUT_README = "README.md"

FUNC_START = "([a-zA-Z_]+)\(\) {"
FUNC_END = "^}$"

DESC_PRE = "# desc: "
USAGE_PRE = "# usage: "
REQUIRE_PRE = "# requires: "

CURRENT_LINE = 0

with open(INPUT, "r") as f:
	SOURCE = [l.strip("\n") for l in f.readlines()]

def blank_line(line_num):
	return SOURCE[line_num].strip() == ""

def preamble_line(line_num):
	return SOURCE[line_num].startswith("# ")

def get_preamble(start_line):
	preamble = []
	for line_num in range(start_line, 0, -1):
		if preamble_line(line_num):
			preamble.append(SOURCE[line_num])
		if blank_line(line_num):
			break
	preamble.reverse()
	return preamble	

def dissemble_preamble(preamble):
	description = []
	usage = []
	requirements = []
	for p in preamble:
		if p.startswith(DESC_PRE):
			description.append(p[len(DESC_PRE):])
		elif p.startswith(USAGE_PRE):
			usage.append(p[len(USAGE_PRE):])
		elif p.startswith(REQUIRE_PRE):
			requirements.append(p[len(REQUIRE_PRE):])
	return description, usage, requirements

def find_func_end(start_line):
	for line_num in range(start_line, len(SOURCE)-1):
		if re.match(FUNC_END, SOURCE[line_num]):
			return line_num+1

def process_block(block):
	body = "### `%s`" % (block["name"])+"\n\n"
	body += "\n".join(block["description"])+"\n\n"
	body += "\n".join(["\t%s" % (l) for l in block["usage"]])+"\n\n"
	body += "#### source\n\n"+"\n".join(["\t%s" % (l) for l in block["source"]])
	if len(block["requires"]) > 0:
		body += "\n\n#### requires\n\n"
		body += "\n".join(["* [%s](#%s)" % (r, r) for r in block["requires"]])+"\n\n"
	return body

def generate_toc(blocks):
	functions = [b["name"] for b in blocks]
	toc_body = "### table of contents\n\n"
	toc_body += "\n".join(["* [`%s`](#%s)" % (f, f) for f in functions])
	return toc_body

function_blocks = []

for S_LNUM in range(0, len(SOURCE)):
	function = re.search(FUNC_START, SOURCE[S_LNUM])
	if function:
		func_name = function.groups()[0]
		preamble = get_preamble(S_LNUM)
		desc, usage, requires = dissemble_preamble(preamble)
		func_end = find_func_end(S_LNUM)
		function_blocks.append({
			"name": func_name,
			"description": desc,
			"usage": usage,
			"requires": requires,
			"source": SOURCE[S_LNUM:func_end]
		})

markdown_output = []
markdown_output.append(generate_toc(function_blocks))
for block in function_blocks:
	markdown_output.append(process_block(block))

markdown_output = "\n\n".join(markdown_output)

with open(INPUT_README, "r") as plain_r:
	with open(OUTPUT_README, "w") as new_r:
		new_r.write("\n\n".join([plain_r.read(), markdown_output]))
