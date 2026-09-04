# -*- coding: utf-8 -*-
"""Memory guidance prompts."""

MEMORY_GUIDANCE = {
    "zh": (
        "# 长期记忆\n\n"
        "- `MEMORY.md` 是你的核心长期记忆。你可以在主会话中自由读取、编辑和更新"
        "这个文件；用户也可能编辑它。\n"
        "- `{daily_dir}/YYYY-MM-DD.md` 是你的日记本和每日笔记，你同样可以自由读取、"
        "编辑和更新。它还包含当天 `{daily_dir}/YYYY-MM-DD/{{topic}}.md` 记忆笔记的索引；"
        "需要更多细节时，可沿索引"
        "渐进式展开。\n"
        "- `{daily_dir}/YYYY-MM-DD/{{topic}}.md` 是按主题命名的 session 记忆笔记，"
        "由后台异步任务总结和维护，通常不需要你主动管理。\n"
        "{search_guidance}"
    ),
    "en": (
        "# Long-term Memory\n\n"
        "- `MEMORY.md` is your core long-term memory. In the main "
        "session, you may freely read, edit, and update it; the user may edit "
        "it too.\n"
        "- `{daily_dir}/YYYY-MM-DD.md` is your journal and daily note. "
        "You may also freely read, edit, and update it. It contains an index "
        "of that day's `{daily_dir}/YYYY-MM-DD/{{topic}}.md` memory notes; "
        "progressively follow the index when more detail is needed.\n"
        "- `{daily_dir}/YYYY-MM-DD/{{topic}}.md` is a topic-named memory note "
        "for an individual session. A background asynchronous task "
        "summarizes and maintains these notes, so you normally do not need to "
        "manage them yourself.\n"
        "{search_guidance}"
    ),
}

MEMORY_SEARCH_GUIDANCE = {
    "zh": (
        "- 你的个人知识库包括 `{daily_dir}` 和 `{digest_dir}` 下的所有 Markdown 文件。"
        "不要一上来就检索：能直接回答的先答。"
        "只有对话过程中明确需要用户过去的事实、偏好、决策或经验时，再使用 "
        "`memory_search` 检索个人知识库。"
        "检索结果会包含相关内容片段及其文件路径；如果片段不足以回答问题，"
        "再使用 `read_file` 按路径渐进式展开，只读取当前任务所需的内容。"
    ),
    "en": (
        "- Your personal knowledge base consists of all Markdown files under "
        "`{daily_dir}` and `{digest_dir}`. "
        "Do not search on the first reply by default; answer directly when "
        "you can. Call `memory_search` only when you clearly need the user's "
        "past facts, preferences, decisions, or experience during the "
        "conversation. Results include relevant excerpts and file paths; if "
        "an excerpt is insufficient, use `read_file` on its path to "
        "progressively expand the context, reading only what the current "
        "task requires."
    ),
}

SHARED_KB_SEARCH_GUIDANCE = {
    "zh": (
        "- 共享业务知识库挂载在 `{knowledge_dir}/`（跨 Agent 维护的 published 节点）。"
        "不要一上来就检索：能直接回答的先答。"
        "只有对话过程中明确需要业务口径、流程、测试用例或缺陷模式等知识时，再使用 "
        "`memory_search`（默认 scope 为共享 KB）；需要个人日记/摘要时用 "
        "`scope=agent`，两者都要时用 `scope=all`。"
        "可用 `save_to_knowledge` 显式写入或修订 published 节点。"
    ),
    "en": (
        "- A shared knowledge base is mounted at `{knowledge_dir}/` (published "
        "nodes maintained across agents). "
        "Do not search on the first reply by default; answer directly when "
        "you can. Call `memory_search` only when you clearly need business "
        "rules, procedures, test cases, or defect patterns during the "
        "conversation (default scope hits the shared KB); use `scope=agent` "
        "for private daily/digest notes and `scope=all` to combine both. "
        "Use `save_to_knowledge` to publish or refine a shared node "
        "explicitly."
    ),
}


def build_memory_guidance_prompt(
    language: str = "zh",
    *,
    memory_search_enabled: bool = True,
    daily_dir: str = "memory",
    digest_dir: str = "digest",
    knowledge_enabled: bool = False,
    knowledge_dir: str = "knowledge",
) -> str:
    """Build guidance for the memory capabilities exposed to the agent."""
    template = MEMORY_GUIDANCE.get(language, MEMORY_GUIDANCE["en"])
    search_template = MEMORY_SEARCH_GUIDANCE.get(
        language,
        MEMORY_SEARCH_GUIDANCE["en"],
    )
    kb_template = SHARED_KB_SEARCH_GUIDANCE.get(
        language,
        SHARED_KB_SEARCH_GUIDANCE["en"],
    )
    normalized_daily_dir = daily_dir.strip("/") or "memory"
    normalized_digest_dir = digest_dir.strip("/") or "digest"
    normalized_knowledge_dir = knowledge_dir.strip("/") or "knowledge"
    search_guidance = ""
    if memory_search_enabled:
        if knowledge_enabled:
            search_guidance = kb_template.format(
                knowledge_dir=normalized_knowledge_dir,
            )
        else:
            search_guidance = search_template.format(
                daily_dir=normalized_daily_dir,
                digest_dir=normalized_digest_dir,
            )
    return template.format(
        daily_dir=normalized_daily_dir,
        digest_dir=normalized_digest_dir,
        search_guidance=search_guidance,
    )
