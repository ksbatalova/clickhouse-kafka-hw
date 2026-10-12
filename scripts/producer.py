import argparse
import csv
import json
import sys
import time


from confluent_kafka import Producer

INT_FIELDS = {"population_city", "target"}
FLOAT_FIELDS = {"amount", "lat", "lon", "merchant_lat", "merchant_lon"}


def to_int(value):
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return 0


def to_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def normalize(row):
    """Приводит числовые поля к нужным типам, остальное оставляет строками."""
    result = {}
    for key, value in row.items():
        if key is None:
            continue
        value = (value or "").strip()
        if key in INT_FIELDS:
            result[key] = to_int(value)
        elif key in FLOAT_FIELDS:
            result[key] = to_float(value)
        else:
            result[key] = value
    return result


def delivery_report(err, msg):
    if err is not None:
        print(f"Ошибка доставки: {err}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True, help="путь к CSV")
    parser.add_argument("--topic", default="transactions")
    parser.add_argument("--bootstrap", default="localhost:29092")
    parser.add_argument("--limit", type=int, default=0, help="0 = отправить всё")
    args = parser.parse_args()

    producer = Producer({
        "bootstrap.servers": args.bootstrap,
        "linger.ms": 50,
        "batch.size": 65536,
        "compression.type": "lz4",
        "acks": "1",
    })

    sent = 0
    started = time.time()

    with open(args.file, newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            payload = json.dumps(normalize(row), ensure_ascii=False)
            while True:
                try:
                    producer.produce(
                        args.topic,
                        value=payload.encode("utf-8"),
                        key=(row.get("us_state") or "").encode("utf-8"),
                        on_delivery=delivery_report,
                    )
                    break
                except BufferError:
                    producer.poll(0.5)

            sent += 1
            if sent % 50_000 == 0:
                producer.poll(0)
                print(f"отправлено {sent:,} строк")
            if args.limit and sent >= args.limit:
                break

    producer.flush()
    elapsed = time.time() - started
    print(f"Готово: {sent:,} строк за {elapsed:.1f} с")


if __name__ == "__main__":
    main()