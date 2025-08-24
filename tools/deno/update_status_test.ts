import { assert } from "std/assert/mod.ts";
import { readJson, writeJson } from "./mod.ts";

Deno.test("read/write json roundtrip", async () => {
  const tmp = "./.tmp_test_status.json";
  const sample = { foo: "bar", timestamp: new Date().toISOString() };
  await writeJson(tmp, sample);
  const loaded = await readJson(tmp);
  assert(loaded.foo === "bar");
  await Deno.remove(tmp);
});
