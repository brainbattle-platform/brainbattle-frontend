import { QuestionRow as QuestionRowType } from "@/types/questions.types";
import { QuestionRow } from "./QuestionRow";

export function QuestionsTable({
  questions,
  onEdit,
  onDelete,
  onPublish,
  onUnpublish,
}: {
  questions: QuestionRowType[];
  onEdit: (question: QuestionRowType) => void;
  onDelete: (question: QuestionRowType) => void;
  onPublish: (question: QuestionRowType) => void;
  onUnpublish: (question: QuestionRowType) => void;
}) {
  return (
    <div className="overflow-x-auto rounded-2xl bg-white border border-gray-200 shadow-sm">
      <table className="min-w-full">
        <thead>
          <tr className="text-left text-gray-600 text-sm border-b border-gray-200">
            <th className="px-5 py-3 font-medium">Question</th>
            <th className="px-5 py-3 font-medium">Mode</th>
            <th className="px-5 py-3 font-medium">Lesson ID</th>
            <th className="px-5 py-3 font-medium">Status</th>
            <th className="px-5 py-3 font-medium">Created</th>
            <th className="px-5 py-3 font-medium text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {questions.length === 0 ? (
            <tr>
              <td colSpan={6} className="px-5 py-12 text-center text-gray-500">
                No questions found
              </td>
            </tr>
          ) : (
            questions.map((question) => (
              <QuestionRow
                key={question.id}
                question={question}
                onEdit={() => onEdit(question)}
                onDelete={() => onDelete(question)}
                onPublish={() => onPublish(question)}
                onUnpublish={() => onUnpublish(question)}
              />
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}

