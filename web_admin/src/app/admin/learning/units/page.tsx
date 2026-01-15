"use client";

import { useEffect, useMemo, useState } from "react";
import { UnitsHeader } from "@/components/units/UnitsHeader";
import { UnitsToolbar } from "@/components/units/UnitsToolbar";
import { UnitsTable } from "@/components/units/UnitsTable";
import { UnitRow } from "@/types/units.types";
import { adminContentApi } from "@/lib/api/admin-content";

type PublishedFilter = "All" | "Published" | "Draft";

export default function UnitsPage() {
  const [units, setUnits] = useState<UnitRow[]>([]);
  const [q, setQ] = useState("");
  const [published, setPublished] = useState<PublishedFilter>("All");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch units
  useEffect(() => {
    const fetchUnits = async () => {
      setLoading(true);
      setError(null);
      try {
        const publishedOnly = published === "Published" ? true : undefined;
        const data = await adminContentApi.getUnits(publishedOnly);
        setUnits(data);
      } catch (err: any) {
        console.error("Failed to fetch units:", err);
        setError(err.message || "Failed to load units");
      } finally {
        setLoading(false);
      }
    };

    fetchUnits();
  }, [published]);

  // Filter units by search query
  const filtered = useMemo(() => {
    const text = q.trim().toLowerCase();
    if (!text) return units;

    return units.filter((u) => {
      return (
        u.unitId.toLowerCase().includes(text) ||
        u.title.toLowerCase().includes(text)
      );
    });
  }, [units, q]);

  // Handlers
  const handleAdd = () => {
    // TODO: Open create unit dialog
    console.log("Add unit");
  };

  const handleEdit = (unit: UnitRow) => {
    // TODO: Open edit unit dialog
    console.log("Edit unit:", unit);
  };

  const handleDelete = async (unit: UnitRow) => {
    try {
      await adminContentApi.deleteUnit(unit.id);
      setUnits((prev) => prev.filter((u) => u.id !== unit.id));
    } catch (err: any) {
      alert(`Failed to delete unit: ${err.message}`);
    }
  };

  const handlePublish = async (unit: UnitRow) => {
    try {
      await adminContentApi.publishUnit(unit.id);
      setUnits((prev) =>
        prev.map((u) => (u.id === unit.id ? { ...u, published: true } : u))
      );
    } catch (err: any) {
      alert(`Failed to publish unit: ${err.message}`);
    }
  };

  const handleUnpublish = async (unit: UnitRow) => {
    try {
      await adminContentApi.unpublishUnit(unit.id);
      setUnits((prev) =>
        prev.map((u) => (u.id === unit.id ? { ...u, published: false } : u))
      );
    } catch (err: any) {
      alert(`Failed to unpublish unit: ${err.message}`);
    }
  };

  const handleMoveUp = async (unit: UnitRow) => {
    try {
      const newOrder = Math.max(0, unit.order - 1);
      await adminContentApi.updateUnitOrder(unit.id, newOrder);
      setUnits((prev) =>
        prev.map((u) => (u.id === unit.id ? { ...u, order: newOrder } : u))
      );
    } catch (err: any) {
      alert(`Failed to move unit: ${err.message}`);
    }
  };

  const handleMoveDown = async (unit: UnitRow) => {
    try {
      const newOrder = unit.order + 1;
      await adminContentApi.updateUnitOrder(unit.id, newOrder);
      setUnits((prev) =>
        prev.map((u) => (u.id === unit.id ? { ...u, order: newOrder } : u))
      );
    } catch (err: any) {
      alert(`Failed to move unit: ${err.message}`);
    }
  };

  const handleExport = () => {
    console.log("Export units");
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading units...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-red-500">Error: {error}</div>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <UnitsHeader />

      <UnitsToolbar
        q={q}
        setQ={setQ}
        published={published}
        setPublished={setPublished}
        onAdd={handleAdd}
        onExport={handleExport}
      />

      <UnitsTable
        units={filtered}
        onEdit={handleEdit}
        onDelete={handleDelete}
        onPublish={handlePublish}
        onUnpublish={handleUnpublish}
        onMoveUp={handleMoveUp}
        onMoveDown={handleMoveDown}
      />

      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>
          Showing {filtered.length} of {units.length} units
        </span>
      </div>
    </div>
  );
}

