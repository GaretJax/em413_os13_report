#!/usr/bin/env python3

import csv
import re
from decimal import ROUND_DOWN
from decimal import Decimal as D

import click
from attrs import define, field
from jinja2 import BaseLoader, Environment
from natsort import natsorted
from slugify import slugify


def replacerefs(text, prefix, label=""):
    def repl(match):
        refs = natsorted(re.findall(r"[\d\.]+", match.group(0)))
        refs = ", ".join(
            [
                r"\hyperref[%s:%s]{\textcolor{blue}{%s%s}}" % (prefix, n, label, n)
                for n in refs
            ]
        )
        return f"({refs})"

    text = re.sub(r"\((?:[\d\.]+[,;] ?)*[\d\.]+\)", repl, text)
    return text


def replaceglossary(text, glossary):
    import csv

    with open(glossary) as fh:
        reader = csv.reader(fh)
        rows = iter(reader)
        next(rows)
        terms = [r[0].strip() for r in reader]

    for term in terms:
        text = re.sub(
            f"([^a-zA-Z]){term}([^a-zA-Z])",
            r"\1\\gls[hyper=true]{%s}\2" % slugify(term),
            text,
        )
    return text


class Ref:
    def __contains__(self, coords):
        return False


@define
class Span:
    start: int = field()
    end: int = field()

    @classmethod
    def parse(cls, s):
        assert s
        start, sep, end = s.partition("-")
        start = int(start) if start else None
        end = int(end) + 1 if end else None

        if end is None and not sep:
            end = start + 1
        return cls(start, end)

    def __contains__(self, i):
        if self.start is None and self.end is None:
            return True
        elif self.start is None:
            return i < self.end
        elif self.end is None:
            return self.start <= i
        return self.start <= i < self.end


@define
class Spans:
    spans: list[Span] = field(factory=list)

    @classmethod
    def all(cls):
        return cls([Span(None, None)])

    @classmethod
    def parse(cls, v):
        spans = [Span.parse(s) for s in v.split(",") if s]
        return cls(spans)

    def __contains__(self, i):
        for span in self.spans:
            if i in span:
                return True
        return False

    def filter(self, iterable):
        for i, value in enumerate(iterable):
            if i in self:
                yield value


class RowSpans(Spans):
    def __contains__(self, cell):
        row, col = cell
        if row is None:
            return False
        return super().__contains__(row)


class ColSpans(Spans):
    def __contains__(self, cell):
        row, col = cell
        if col is None:
            return False
        return super().__contains__(col)


@define(kw_only=True)
class WrapperBase:
    priority = 100
    spans: Spans = field()

    def wrap(self, cell, value):
        if cell in self.spans:
            value = self.apply(value)
        return value

    def wrap_row(self, row, value):
        if (row, None) in self.spans:
            value = self.apply_row(value)
        return value

    def apply_row(self, value):
        return value


def quote(text):
    if not text:
        return ""
    t = (
        text.strip()
        .replace("%", r"\%")
        .replace("#", r"\#")
        .replace("&", r"\&")
        .replace("$", r"\$")
        .replace("_", r"\_")
        .replace("{", r"\{")
        .replace("}", r"\}")
        .replace(r"\\", r"\\\\")
    )
    return t


def stripnl(text):
    return text.replace("\n", " ")


class SkippableDictReader(csv.DictReader):
    def __init__(self, f, start_at=0, **kwargs):
        super().__init__(f, **kwargs)
        for i in range(start_at):
            next(self.reader)


def print_table(
    fh, rows, cols, start_at, skip_headers, skip_cols, wrappers, row_template
):
    delimiter = ","
    if fh.name.endswith(".tsv"):
        delimiter = "\t"
    data = SkippableDictReader(fh, start_at=start_at, delimiter=delimiter)
    cols = list(cols.filter(data.fieldnames))
    if skip_cols:
        cols = [c for c in cols if c not in skip_cols]

    if not skip_headers:
        data = [dict(zip(cols, cols))] + list(data)

    for row, data in enumerate(rows.filter(data)):
        print_row(row, data, cols, wrappers, row_template)


def print_row(row, data, cols, wrappers, row_template):
    values = []
    has_value = False
    data = [data[k] for k in cols]
    for col, cell in enumerate(data):
        cell = quote(cell)
        if cell:
            has_value = True
        for wrapper in wrappers:
            cell = wrapper.wrap((row, col), cell)
        values.append(cell)
    value = row_template(values, has_value)
    for wrapper in wrappers:
        value = wrapper.wrap_row(row, value)
    print(value, end="")


@define
class Wrapper(WrapperBase):
    directive: str = field()
    wrap_value: bool = field(default=True)

    def apply(self, value):
        value = value.strip()
        if not value:
            return ""
        if self.wrap_value:
            return rf"\{self.directive}{{{value}}}"
        else:
            space = "" if value.startswith("\\") else " "
            return rf"\{self.directive}{space}{value}"

    @classmethod
    def parse(cls, spans, args):
        return cls(spans=spans, directive=args)


@define
class Bold(Wrapper):
    @classmethod
    def parse(cls, spans, args):
        assert args is None
        return cls(spans=spans, directive="bfseries", wrap_value=False)


@define
class Italic(Wrapper):
    @classmethod
    def parse(cls, spans, args):
        assert args is None
        return cls(spans=spans, directive="itshape", wrap_value=False)


@define
class BackgroundColor(WrapperBase):
    priority = 10
    color: str = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(color=args, spans=spans)

    def apply(self, value):
        return rf"\cellcolor{{{self.color}}}{value}"


@define
class Dot(WrapperBase):
    @classmethod
    def parse(cls, spans, args):
        assert args is None
        return cls(spans=spans)

    def apply(self, value):
        if value.strip():
            return r"\textbullet"
        else:
            return value


@define
class CheckmarkIfValue(WrapperBase):
    value: str = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(value=args, spans=spans)

    def apply(self, value):
        if value.strip() == self.value:
            return r"\cmark"
        else:
            return value


@define
class CrossmarkIfValue(WrapperBase):
    value: str = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(value=args, spans=spans)

    def apply(self, value):
        if value.strip() == self.value:
            return r"\xmark"
        else:
            return value


@define
class List(WrapperBase):
    value: str = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(value=args, spans=spans)

    def apply(self, value):
        if not value.strip():
            return ""
        lines = [rf"\item {line}" for line in value.strip("- ").split("\n- ")]
        return "\n".join([r"\begin{tabitemize}", *lines, r"\end{tabitemize}"])


@define
class TextColor(WrapperBase):
    priority = 100
    color: str = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(color=args, spans=spans)

    def apply(self, value):
        return rf"\color{{{self.color}}}{{{value}}}"


@define
class RoundNumbers(WrapperBase):
    priority = 200
    decimals: int = field()
    rounding = field()

    @classmethod
    def parse(cls, spans, args):
        args = args.split(",")
        rounding = ROUND_DOWN if len(args) > 1 and args[1] == "down" else None
        return cls(decimals=int(args[0]), rounding=rounding, spans=spans)

    def apply(self, value):
        if value.startswith("(") and value.endswith(")"):
            value = f"-{value[1:-1]}"
        if re.match(r"^-?([0-9]+[,.]?)+$", value):
            value = value.replace(",", "")
            value = D(value)
            if self.decimals < 0:
                value /= 10**-self.decimals
                value = value.quantize(D("1."))
            else:
                value = value.quantize(
                    D("1." + "0" * self.decimals), rounding=self.rounding
                )
            value = str(value)
        else:
            if value.strip() == "...":
                value = r"\dots"
            value = f"{{{value}}}"
        return value


@define
class Percent(WrapperBase):
    priority = 200
    decimals: int = field()

    @classmethod
    def parse(cls, spans, args):
        return cls(decimals=int(args), spans=spans)

    def apply(self, value):
        if re.match(r"^-?[0-9,.]+$", value):
            value = value.replace(",", "")
            value = (D(value) * 100).quantize(D("1." + "0" * self.decimals))
            value = rf"\pct{{{value}}}"
        return value


@define
class RowBorderWrapper(WrapperBase):
    priority = 0
    border_top: bool = field(default=False)
    border_bottom: bool = field(default=False)
    border_command: str = field(default="midrule")

    @classmethod
    def parse(cls, spans, args):
        return cls(spans=spans)

    def apply(self, value):
        return value

    def apply_row(self, value):
        if self.border_top:
            value = f"\\{self.border_command}\n{value}"
        return value


@define
class RowWrapper(WrapperBase):
    priority = 1

    @classmethod
    def parse(cls, spans, args):
        return cls(spans=spans)

    def apply(self, value):
        return value

    def apply_row(self, value):
        if value:
            return f"{value}\n\\\\\n"
        else:
            return "\\\\\n"


MODIFIERS = {
    "bold": Bold,
    "italic": Italic,
    "bg": BackgroundColor,
    "fg": TextColor,
    "round": RoundNumbers,
    "percent": Percent,
    "dot": Dot,
    "list": List,
    "cmark-if": CheckmarkIfValue,
    "xmark-if": CrossmarkIfValue,
    "wrap": Wrapper,
}


def parse_modifier(m, spans_cls):
    spec = m.split(":", 2)
    if len(spec) == 3:
        spans, key, args = spec
    elif len(spec) == 2:
        spans, key = spec
        args = None
    else:
        raise ValueError(f"Invalid modifier spec: {m}")

    spans = spans_cls.parse(spans)
    modifier = MODIFIERS[key]
    return modifier.parse(spans, args)


def simple_row(values, has_value):
    return " & ".join(values) if has_value else ""


@click.command()
@click.option("-s", "--start-at", default=0)
@click.option("-r", "--row-modifier", "row_modifiers", multiple=True)
@click.option("-c", "--col-modifier", "col_modifiers", multiple=True)
@click.option("-t", "--border-top", "border_top")
@click.option(
    "-b",
    "--border-bottom/--no-bb",
    "border_bottom",
    is_flag=True,
    default=True,
)
@click.option(
    "-m",
    "--border-middle/--no-bm",
    "border_mid",
    is_flag=True,
    default=True,
)
@click.option(
    "--border-middle-command",
    "border_mid_cmd",
    default="midrule",
)
@click.option(
    "--skip-headers/--no-skip-headers",
    "skip_headers",
    is_flag=True,
    default=True,
)
@click.option("--rows")
@click.option("--cols")
@click.option("--skip-cols")
@click.option("--template", type=click.File("r"))
@click.argument("path", type=click.File("r"))
def main(
    path,
    rows,
    cols,
    start_at,
    skip_cols,
    row_modifiers,
    col_modifiers,
    border_top,
    border_mid,
    border_mid_cmd,
    border_bottom,
    skip_headers,
    template,
):
    rows = Spans.parse(rows) if rows else Spans.all()
    cols = Spans.parse(cols) if cols else Spans.all()
    skip_cols = skip_cols.split(",") if skip_cols else []

    wrappers = [
        RowBorderWrapper(
            spans=(
                RowSpans.parse(border_top) if border_top else RowSpans([Span(1, None)])
            ),
            border_top=border_mid,
            border_bottom=False,
            border_command=border_mid_cmd,
        ),
        RowWrapper(spans=RowSpans.all()),
    ]

    for m in row_modifiers:
        wrappers.append(parse_modifier(m, RowSpans))
    for m in col_modifiers:
        wrappers.append(parse_modifier(m, ColSpans))

    wrappers.sort(key=lambda w: w.priority, reverse=True)

    if template:
        env = Environment(
            loader=BaseLoader,
            autoescape=False,
            block_start_string="<@",
            block_end_string="@>",
            variable_start_string="<<",
            variable_end_string=">>",
        )
        env.filters.update(
            {
                "escape": quote,
                "stripnl": stripnl,
                "replacerefs": replacerefs,
                "glossarize": replaceglossary,
            }
        )
        jtemplate = env.from_string(template.read())

        def template_func(values, has_value):
            return jtemplate.render(r=values, has_value=has_value)
    else:
        template_func = simple_row

    print_table(
        path, rows, cols, start_at, skip_headers, skip_cols, wrappers, template_func
    )
    if border_bottom:
        print(r"\midrule")


if __name__ == "__main__":
    main()
