# -*- coding: utf-8 -*-
"""Tests for default shared knowledge-base migration."""

import json
from threading import Lock

from qwenpaw.config.config import (
    AgentProfileConfig,
    AgentProfileRef,
    AgentsConfig,
    Config,
    load_agent_config,
    migrate_shared_knowledge_base_config,
)
from qwenpaw.config import utils as config_utils


def test_migrate_empty_knowledge_base_id():
    data = {
        "running": {
            "reme_light_memory_config": {
                "knowledge_base_id": "",
            },
        },
    }

    assert migrate_shared_knowledge_base_config(data) is True
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "zhb_kb"
    )


def test_migrate_missing_reme_light_memory_config():
    data = {"running": {}}

    assert migrate_shared_knowledge_base_config(data) is True
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "zhb_kb"
    )


def test_explicit_knowledge_base_id_is_preserved():
    data = {
        "running": {
            "reme_light_memory_config": {
                "knowledge_base_id": "custom_kb",
            },
        },
    }

    assert migrate_shared_knowledge_base_config(data) is False
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "custom_kb"
    )


def test_migrate_legacy_zhb_id_to_zhb_kb():
    data = {
        "running": {
            "reme_light_memory_config": {
                "knowledge_base_id": "zhb",
            },
        },
    }

    assert migrate_shared_knowledge_base_config(data) is True
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "zhb_kb"
    )


def test_migrate_legacy_auto_kb_id_to_shared_default():
    data = {
        "running": {
            "reme_light_memory_config": {
                "knowledge_base_id": "kb_biz-agent",
            },
        },
    }

    assert migrate_shared_knowledge_base_config(data, agent_id="biz-agent") is True
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "zhb_kb"
    )


def test_legacy_auto_kb_id_does_not_remap_other_agents():
    data = {
        "running": {
            "reme_light_memory_config": {
                "knowledge_base_id": "kb_biz-agent",
            },
        },
    }

    assert migrate_shared_knowledge_base_config(data, agent_id="other") is False
    assert (
        data["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "kb_biz-agent"
    )


def test_loaded_agent_config_migration_persists(tmp_path, monkeypatch):
    workspace_dir = tmp_path / "workspaces" / "agent"
    workspace_dir.mkdir(parents=True)
    agent_config_path = workspace_dir / "agent.json"
    raw = AgentProfileConfig(id="agent", name="Agent").model_dump(
        exclude_none=True,
    )
    raw["running"] = {
        "reme_light_memory_config": {
            "knowledge_base_id": "",
        },
    }
    agent_config_path.write_text(json.dumps(raw), encoding="utf-8")

    root_config = Config(
        agents=AgentsConfig(
            active_agent="agent",
            profiles={
                "agent": AgentProfileRef(
                    id="agent",
                    workspace_dir=str(workspace_dir),
                ),
            },
        ),
    )
    monkeypatch.setattr(config_utils, "load_config", lambda: root_config)
    monkeypatch.setattr(config_utils, "_agent_config_cache", {})
    monkeypatch.setattr(config_utils, "_agent_config_lock", Lock())

    config = load_agent_config("agent")
    persisted = json.loads(agent_config_path.read_text(encoding="utf-8"))

    assert (
        config.running.reme_light_memory_config.knowledge_base_id == "zhb_kb"
    )
    assert (
        persisted["running"]["reme_light_memory_config"]["knowledge_base_id"]
        == "zhb_kb"
    )
