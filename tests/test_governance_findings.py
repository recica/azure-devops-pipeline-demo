from main import build_governance_findings, count_findings_by_severity

SAMPLE_DATA = {
    "resource_groups": [
        {"name": "rg-locked", "location": "westeurope", "has_lock": True},
        {"name": "rg-unlocked", "location": "westeurope", "has_lock": False},
    ],
    "unattached_disks": [
        {"name": "disk-orphan", "resource_group": "rg-unlocked", "location": "westeurope", "size_gb": 64},
    ],
    "unassociated_public_ips": [
        {"name": "pip-orphan", "resource_group": "rg-unlocked", "location": "westeurope"},
    ],
}


def test_build_governance_findings_flags_unlocked_resource_group():
    findings = build_governance_findings(SAMPLE_DATA)

    resources = [finding["resource"] for finding in findings]

    assert "rg-unlocked" in resources
    assert "rg-locked" not in resources


def test_build_governance_findings_flags_orphaned_resources():
    findings = build_governance_findings(SAMPLE_DATA)

    resources = [finding["resource"] for finding in findings]

    assert "disk-orphan" in resources
    assert "pip-orphan" in resources


def test_build_governance_findings_count_matches_severity():
    findings = build_governance_findings(SAMPLE_DATA)

    assert len(findings) == 3
    assert count_findings_by_severity(findings, "Medium") == 1
    assert count_findings_by_severity(findings, "Low") == 2


def test_no_findings_when_everything_is_clean():
    clean_data = {
        "resource_groups": [{"name": "rg-clean", "location": "westeurope", "has_lock": True}],
        "unattached_disks": [],
        "unassociated_public_ips": [],
    }

    assert build_governance_findings(clean_data) == []
