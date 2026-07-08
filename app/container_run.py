from main import (
    export_to_csv,
    export_to_markdown,
    load_governance_data,
    show_governance_findings,
    show_summary,
)


def run():
    data = load_governance_data()

    show_summary(data)
    show_governance_findings(data)
    export_to_csv(data)
    export_to_markdown(data)


if __name__ == "__main__":
    run()
