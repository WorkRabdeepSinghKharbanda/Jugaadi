export function JsonLd({ data }: { data: Record<string, unknown>[] }) {
  return (
    <>
      {data.map((node, i) => (
        <script key={i} type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(node) }} />
      ))}
    </>
  );
}
