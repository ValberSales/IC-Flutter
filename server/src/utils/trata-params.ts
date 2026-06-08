import { Between, In, IsNull, Like, Not, Raw } from "typeorm";

export function trataParams(searchParams: any[]) {
  for (const sp of searchParams) {
    trataParam(sp);
  }
  return searchParams;
}

function trataParam(sp: any) {
  for (const field in sp) {
    if (typeof sp[field] == "string" && (sp[field] as string).includes("%")) {
      const value = sp[field] + "";
      sp[field] = Raw((alias) => `unaccent(lower(${alias})) ILIKE unaccent(lower('${value}'))`);
    } else if (field.startsWith("in-")) {
      sp[field.replace("in-", "")] = In(sp[field] as any[]);
      sp[field] = undefined;
    } else if (field.startsWith("between-")) {
      sp[field.replace("between-", "")] = Between(sp[field][0], sp[field][1]);
      sp[field] = undefined;
    } else if (field.startsWith("not-")) {
      if (sp[field] == null) {
        sp[field.replace("not-", "")] = Not(IsNull())
      } else {
        sp[field.replace("not-", "")] = Not(sp[field]);
      }
      sp[field] = undefined;
    } else if (sp[field] == null) {
      sp[field] = IsNull();
    } else if (
      typeof sp[field] == "string" &&
      (sp[field] as string).startsWith("@!")
    ) {
      sp[field] = Not((sp[field] as string).replace("@!", ""));
    } else if (typeof sp[field] == 'object') {
      sp[field] = trataParam(sp[field]);
      continue;

    }
  }
  return sp;
}