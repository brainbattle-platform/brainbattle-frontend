export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
};

export type MenuItem = {
  label: string;
  icon: React.ElementType;
  href?: string;
  children?: MenuItem[];
};
