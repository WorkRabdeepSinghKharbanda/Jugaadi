export function JsonLd({ data }: { data: Record<string, unknown>[] }) {
  return (
    <>
      {data.map((node, i) => (
        // eslint-disable-next-line react/no-danger
        <script key={i} type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(node) }} />
      ))}
    </>
  );
}
