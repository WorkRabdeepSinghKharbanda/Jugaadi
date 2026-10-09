"use client";

import { useState } from "react";

export function HowItWorksTabs({
  heading,
  ownerLabel,
  workerLabel,
  ownerSteps,
  workerSteps,
}: {
  heading: string;
  ownerLabel: string;
  workerLabel: string;
  ownerSteps: string[];
  workerSteps: string[];
}) {
  const [tab, setTab] = useState<"owner" | "worker">("owner");
  const steps = tab === "owner" ? ownerSteps : workerSteps;

  return (
    <section>
      <h2>{heading}</h2>
      <div className="tabs-widget">
        <div className="tab-buttons" role="tablist">
          <button
            type="button"
            role="tab"
            aria-selected={tab === "owner"}
            className={tab === "owner" ? "active" : ""}
            onClick={() => setTab("owner")}
          >
            {ownerLabel}
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={tab === "worker"}
            className={tab === "worker" ? "active" : ""}
            onClick={() => setTab("worker")}
          >
            {workerLabel}
          </button>
        </div>
        <ol>
          {steps.map((s) => (
            <li key={s}>{s}</li>
          ))}
        </ol>
      </div>
    </section>
  );
}
