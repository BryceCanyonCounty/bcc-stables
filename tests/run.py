"""Offline Lua 5.4 contract tests. Requires lupa; no FXServer or database needed."""
from pathlib import Path
import os
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
os.chdir(root)
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(Path('tests/foundation.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/client.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/comparison.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/entity_proof.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/entity_proof_client.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/operations.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/persistence.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/repository_proof.lua').read_text(encoding='utf-8'))
