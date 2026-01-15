import { Unit } from "@/lib/api/admin-content";

export type UnitRow = Unit & {
  lessonsCount?: number;
};

