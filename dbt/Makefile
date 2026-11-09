.PHONY: deps seed run test docs lint fix all

deps:
	dbt deps

seed:
	dbt seed

run:
	dbt run

test:
	dbt test

docs:
	dbt docs generate && dbt docs serve

lint:
	sqlfluff lint models tests --dialect clickhouse

fix:
	sqlfluff fix models tests --dialect clickhouse

all: deps seed run test
