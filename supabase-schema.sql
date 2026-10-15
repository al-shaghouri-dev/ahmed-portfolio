-- نفّذ هذا الملف في Supabase > SQL Editor.
-- محتوى الموقع العام يمكن قراءته للجميع، لكن التعديل يتطلب مستخدمًا مسجّلًا.
-- مهم: عطّل التسجيل العام من Authentication > Settings، وأنشئ حسابك الإداري بنفسك.
create table if not exists public.portfolio_content (
  id bigint primary key check (id = 1),
  content jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.portfolio_content enable row level security;

drop policy if exists "Public can read portfolio" on public.portfolio_content;
create policy "Public can read portfolio"
  on public.portfolio_content for select
  to anon, authenticated
  using (true);

drop policy if exists "Authenticated admins can update portfolio" on public.portfolio_content;
create policy "Authenticated admins can update portfolio"
  on public.portfolio_content for all
  to authenticated
  using (auth.uid() is not null)
  with check (auth.uid() is not null);

insert into public.portfolio_content (id, content)
values (1, '{
  "name":"أحمد محمد علي شخاشيرو",
  "kicker":"الموقع الشخصي · السيرة الذاتية",
  "lead":"طالب تقنية معلومات في السنة الثالثة، مهتم بالأمن السيبراني وتطوير الويب والبرمجة وبناء حلول رقمية عملية.",
  "about":"أدرس تقنية المعلومات في الجامعة العربية المفتوحة – فرع مصر، بالشراكة مع The Open University في المملكة المتحدة. أمتلك خبرة عملية في البرمجة وتطوير الويب واستخدام أدوات إدارة الأعمال والبيانات، وأسعى إلى تطوير مهاراتي في الأمن السيبراني وتصميم وتنفيذ الأنظمة.",
  "objective":"تطوير خبرة عملية في مجالات البرمجة وتقنية المعلومات، مع التركيز على الأمن السيبراني وتطوير الويب وتصميم وتنفيذ الأنظمة.",
  "location":"دمشق، سوريا",
  "specialty":"تقنية المعلومات — اهتمام بالأمن السيبراني وتطوير الويب",
  "english":"B1+",
  "email":"ahmhdahmhdmhmhdale@gmail.com",
  "phone":"+963946540671",
  "accent":"#d9b46a",
  "background":"#0b0d12",
  "imageUrl":"",
  "experiences":[{"title":"Creative Kids / EGYCO","period":"2025","description":"مشاركة في الأعمال التشغيلية وإدارة بيانات المبيعات والعملاء واستخدام جداول البيانات وأدوات متابعة الأعمال."},{"title":"JOVA Co.","period":"2025","description":"خبرة عملية ضمن بيئة عمل تجارية، مع مهام تنظيمية وإدارية. يُرجى مراجعة التفاصيل والتاريخ قبل النشر."},{"title":"Trojan Company","period":"2024","description":"خبرة عملية ضمن بيئة عمل تقنية/تشغيلية. يُرجى مراجعة المسمى والمهام قبل النشر."},{"title":"أنظمة إدارة الأعمال","period":"خبرة تقنية","description":"استخدام أدوات مثل Al-Mohtaseb وAl-Ameen وExcel وWord لتنظيم البيانات ومتابعة العمليات."}],
  "projects":[{"title":"نظام إدارة العملاء CRM","description":"تصور لنظام ينظم بيانات العملاء ويتابع المبيعات والمهام ضمن واجهة موحدة.","tags":["CRM","إدارة بيانات","واجهة ويب"]},{"title":"تطوير الويب","description":"تصميم صفحات ويب وتجارب استخدام متجاوبة مع تنظيم المحتوى والواجهات.","tags":["HTML","CSS","JavaScript"]},{"title":"أدوات وتقارير الأعمال","description":"تنظيم بيانات العمل والجداول وإعداد تقارير تساعد على متابعة العمليات اليومية.","tags":["Excel","تقارير","عمليات"]}],
  "skills":["Python","Java","HTML / CSS / JavaScript","Web Development","Database Management","API Integration","Networking","Cybersecurity Fundamentals","Windows / Linux","Microsoft Excel","Microsoft Word","Al-Mohtaseb","Al-Ameen"],
  "education":[{"title":"بكالوريوس تقنية المعلومات","label":"التعليم","description":"الجامعة العربية المفتوحة (AOU) – فرع مصر، بالشراكة مع The Open University – UK."},{"title":"Pearson English","label":"اللغة الإنجليزية","description":"مستوى اللغة الإنجليزية: B1+ وفق المعلومات المتوفرة."},{"title":"التطوير المستمر","label":"دورات وشهادات","description":"يمكن إضافة أسماء الدورات والشهادات وتواريخها بعد مراجعتها."}]
}'::jsonb)
on conflict (id) do nothing;

-- Storage: إنشاء bucket عام لقراءة صورة الملف الشخصي، مع السماح برفع الملفات للمستخدم المسجل فقط.
insert into storage.buckets (id, name, public)
values ('portfolio-media', 'portfolio-media', true)
on conflict (id) do nothing;

drop policy if exists "Public can view portfolio media" on storage.objects;
create policy "Public can view portfolio media"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'portfolio-media');

drop policy if exists "Authenticated can upload portfolio media" on storage.objects;
create policy "Authenticated can upload portfolio media"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'portfolio-media' and auth.uid() is not null);

drop policy if exists "Authenticated can update portfolio media" on storage.objects;
create policy "Authenticated can update portfolio media"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'portfolio-media' and auth.uid() is not null)
  with check (bucket_id = 'portfolio-media' and auth.uid() is not null);
