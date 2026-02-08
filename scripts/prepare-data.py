#!/usr/bin/env python3

import csv
import datetime
import sys
import click


def quote_header(k):
    return k.replace(" ", "").replace("_", "")


def quote_value(v):
    t = v.strip().replace("%", r"\%").replace("#", r"\#").replace("&", r"\&")
    return t


class LaTeXDictWriter(csv.DictWriter):
    def writeheader(self):
        return super().writerow({k: quote_header(k) for k in self.fieldnames})

    def writerow(self, data):
        return super().writerow({k: quote_value(v) for k, v in data.items()})


def keeprow(row, filters, excludes):
    for f in filters:
        key, value = f.split(":")
        if row[key] != value:
            return False
    for e in excludes:
        key, value = e.split(":")
        if row[key] == value:
            return False
    return True


def iterrows(reader, filters, excludes):
    for row in reader:
        if keeprow(row, filters, excludes):
            yield row


def next_month(date):
    year, month, day = date.year, date.month, date.day
    if month == 12:
        month = 1
        year += 1
    else:
        month += 1
    return datetime.date(year, month, 1)


def itermonths(from_date, to_date, frequency=1):
    date = next_month(from_date)
    to_date = next_month(to_date)
    while date <= to_date:
        if (date.month - 1) % frequency == 0:
            yield date
        date = next_month(date)


@click.command()
@click.option("-t", "--dt", "--date-ticks", "date_ticks")
@click.option("-s", "--from-date", "from_date")
@click.option("-u", "--until-date", "to_date")
@click.option("-f", "--filter", "filters", multiple=True)
@click.option("-e", "--exclude", "excludes", multiple=True)
@click.argument("fh", type=click.File("r"))
@click.argument("name")
def main(fh, name, from_date, to_date, filters, excludes, date_ticks):
    reader = csv.DictReader(fh)

    writer = LaTeXDictWriter(sys.__stdout__, [f for f in reader.fieldnames if f])

    print(
        r"""\pgfplotstableread[
  col sep=comma,
  header=has colnames,
  format=inline,
]{"""
    )

    writer.writeheader()

    if date_ticks:
        date_field, frequency = date_ticks.split(":")
        if frequency == "monthly":
            frequency = 1
            datefmt = str
        elif frequency == "quarterly":
            frequency = 3
            datefmt = str
        elif frequency == "semi-yearly":
            frequency = 6
            datefmt = str
        elif frequency == "yearly":
            frequency = 12
            datefmt = str
        min_date, max_date = None, None

    if from_date or to_date:
        assert date_ticks

        if from_date:
            from_date = datetime.date.fromisoformat(from_date)
            min_date = from_date
        if to_date:
            to_date = datetime.date.fromisoformat(to_date)
            max_date = to_date

    for row in iterrows(reader, filters, excludes):
        if date_ticks:
            date = datetime.date.fromisoformat(row[date_field])
            if from_date and date < from_date:
                continue
            if to_date and date > to_date:
                continue
            min_date = date if min_date is None else min(date, min_date)
            max_date = date if max_date is None else max(date, max_date)
        row.pop('', None)
        writer.writerow(row)

    print(rf"}}\{name}")

    if date_ticks:
        ticks = [datefmt(d) for d in itermonths(min_date, max_date, frequency)]

        print(rf"\def\{name}ticks{{{','.join(ticks)}}}")


if __name__ == "__main__":
    main()
