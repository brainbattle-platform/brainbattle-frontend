import { QuestionRow as QuestionRowType } from "@/types/questions.types";
import { PublishedBadge } from "../units/PublishedBadge";
import { ModeBadge } from "./ModeBadge";
import { QuestionActionMenu } from "./QuestionActionMenu";

const fmtDate = (iso?: string) => {
  if (!iso) return "—";
  const d = new Date(iso);
  return d.toLocaleDateString("en-US", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
};

export function QuestionRow({
  question,
  onEdit,
  onDelete,
  onPublish,
  onUnpublish,
}: {
  question: QuestionRowType;
  onEdit: () => void;
  onDelete: () => void;
  onPublish: () => void;
  onUnpublish: () => void;
}) {
  return (
    <tr className="border-b border-gray-100 hover:bg-gray-50 transition">
      <td className="px-5 py-4">
        <div className="flex flex-col gap-1">
          <span className="font-semibold text-gray-900 line-clamp-2">
            {question.prompt}
          </span>
          <span className="text-xs text-gray-500">{question.questionId}</span>
        </div>
      </td>
      <td className="px-5 py-4">
        <ModeBadge mode={question.mode} />
      </td>
      <td className="px-5 py-4 text-sm text-gray-600">
        {question.lessonId}
      </td>
      <td className="px-5 py-4">
        <PublishedBadge published={question.published} />
      </td>
      <td className="px-5 py-4 text-sm text-gray-500">
        {fmtDate(question.createdAt)}
      </td>
      <td className="px-5 py-4 text-center">
        <QuestionActionMenu
          question={question}
          onEdit={onEdit}
          onDelete={onDelete}
          onPublish={onPublish}
          onUnpublish={onUnpublish}
        />
      </td>
    </tr>
  );
}

