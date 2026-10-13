import { ImageResponse } from "next/og";

export const alt = "Jugaadi — Find help. Find work. Same day.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function OpengraphImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: 96,
          background: "#0B0B0F",
          fontFamily: "sans-serif",
        }}
      >
        <div style={{ display: "flex", fontSize: 148, fontWeight: 700, color: "#FFFFFF" }}>
          Jug<span style={{ color: "#E8A33D" }}>aadi</span>
        </div>
        <div style={{ display: "flex", marginTop: 24, fontSize: 52, color: "#E8A33D" }}>Find help. Find work. Same day.</div>
      </div>
    ),
    size
  );
}
