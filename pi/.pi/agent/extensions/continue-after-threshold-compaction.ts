import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_compact", async (event) => {
    if (event.reason !== "threshold" || event.willRetry) return;

    await pi.sendUserMessage(
      "Continue the previous task from the compacted state. Review the summary and current files/diff, then proceed with the next unfinished step. Do not stop merely because compaction completed.",
      { deliverAs: "followUp" },
    );
  });
}
