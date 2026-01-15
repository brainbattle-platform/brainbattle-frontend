"use client";

import { useEffect, useMemo, useState } from "react";
import { QuestionsHeader } from "@/components/questions/QuestionsHeader";
import { QuestionsToolbar } from "@/components/questions/QuestionsToolbar";
import { QuestionsTable } from "@/components/questions/QuestionsTable";
import { QuestionRow } from "@/types/questions.types";
import { adminContentApi } from "@/lib/api/admin-content";

type PublishedFilter = "All" | "Published" | "Draft";
type ModeFilter = "All" | "listening" | "speaking" | "reading" | "writing";

export default function QuestionsPage() {
  const [questions, setQuestions] = useState<QuestionRow[]>([]);
  const [q, setQ] = useState("");
  const [published, setPublished] = useState<PublishedFilter>("All");
  const [mode, setMode] = useState<ModeFilter>("All");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch questions
  useEffect(() => {
    const fetchQuestions = async () => {
      setLoading(true);
      setError(null);
      try {
        const publishedOnly = published === "Published" ? true : undefined;
        const modeFilter = mode !== "All" ? mode : undefined;
        const data = await adminContentApi.getQuestions({
          publishedOnly,
          mode: modeFilter,
        });
        setQuestions(data);
      } catch (err: any) {
        console.error("Failed to fetch questions:", err);
        setError(err.message || "Failed to load questions");
      } finally {
        setLoading(false);
      }
    };

    fetchQuestions();
  }, [published, mode]);

  // Filter questions by search query
  const filtered = useMemo(() => {
    const text = q.trim().toLowerCase();
    if (!text) return questions;

    return questions.filter((q) => {
      return (
        q.questionId.toLowerCase().includes(text) ||
        q.prompt.toLowerCase().includes(text) ||
        q.lessonId.toLowerCase().includes(text)
      );
    });
  }, [questions, q]);

  // Handlers
  const handleAdd = () => {
    // TODO: Open create question dialog
    console.log("Add question");
  };

  const handleEdit = (question: QuestionRow) => {
    // TODO: Open edit question dialog
    console.log("Edit question:", question);
  };

  const handleDelete = async (question: QuestionRow) => {
    try {
      await adminContentApi.deleteQuestion(question.id);
      setQuestions((prev) => prev.filter((q) => q.id !== question.id));
    } catch (err: any) {
      alert(`Failed to delete question: ${err.message}`);
    }
  };

  const handlePublish = async (question: QuestionRow) => {
    try {
      await adminContentApi.publishQuestion(question.id);
      setQuestions((prev) =>
        prev.map((q) => (q.id === question.id ? { ...q, published: true } : q))
      );
    } catch (err: any) {
      alert(`Failed to publish question: ${err.message}`);
    }
  };

  const handleUnpublish = async (question: QuestionRow) => {
    try {
      await adminContentApi.unpublishQuestion(question.id);
      setQuestions((prev) =>
        prev.map((q) => (q.id === question.id ? { ...q, published: false } : q))
      );
    } catch (err: any) {
      alert(`Failed to unpublish question: ${err.message}`);
    }
  };

  const handleExport = () => {
    console.log("Export questions");
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading questions...</div>
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
      <QuestionsHeader />

      <QuestionsToolbar
        q={q}
        setQ={setQ}
        published={published}
        setPublished={setPublished}
        mode={mode}
        setMode={setMode}
        onAdd={handleAdd}
        onExport={handleExport}
      />

      <QuestionsTable
        questions={filtered}
        onEdit={handleEdit}
        onDelete={handleDelete}
        onPublish={handlePublish}
        onUnpublish={handleUnpublish}
      />

      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>
          Showing {filtered.length} of {questions.length} questions
        </span>
      </div>
    </div>
  );
}

