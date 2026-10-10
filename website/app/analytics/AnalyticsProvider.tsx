"use client";

import { createContext, useContext, useEffect, useMemo, type ReactNode } from "react";
import { createAnalyticsClient, type AnalyticsClient } from "./lib";

const AnalyticsContext = createContext<AnalyticsClient | null>(null);

export function AnalyticsProvider({ children }: { children: ReactNode }) {
  const client = useMemo(() => createAnalyticsClient(), []);

  useEffect(() => {
    client.init();
  }, [client]);

  return <AnalyticsContext.Provider value={client}>{children}</AnalyticsContext.Provider>;
}

export function useAnalytics(): AnalyticsClient {
  const client = useContext(AnalyticsContext);
  return client ?? createAnalyticsClient({ enabled: false });
}
