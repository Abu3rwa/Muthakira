const EXAM_COLUMNS_REQUIRED =
  'exam_key, exam_year, session, class_level, subject, language, duration_minutes, total_marks, source, rights_note, status';
const EXAM_COLUMNS_OPTIONAL = 'stream, instructions, rights_status';
const STIMULUS_COLUMNS_REQUIRED = 'exam_key, stimulus_key, kind, text';
const STIMULUS_COLUMNS_OPTIONAL = 'title, sort_order';
const QUESTION_COLUMNS_REQUIRED = 'exam_key, path, type, text, key_status, sort_order';
const QUESTION_COLUMNS_OPTIONAL =
  'stimulus_key, options, key, accepted_alternatives, marks, criteria, model_answer, explanation, topic_tags, normalisation, access, difficulty, practice_eligible, misconceptions, marking_method';

const EXAMPLE_EXAMS =
  'exam_key,exam_year,session,class_level,stream,subject,language,duration_minutes,total_marks,instructions,source,rights_note,rights_status,status\n' +
  'sample-2026-ar-math,2026,الدور الأول,الصف التاسع,,الرياضيات,ar,90,17,أجب عن جميع الأسئلة واكتب خطوات الحل.,ورقة تجريبية أُنشئت لاستيراد مذكرة,محتوى أصلي من إعداد مذكرة,owner_authored,draft';

const EXAMPLE_STIMULI =
  'exam_key,stimulus_key,kind,title,text,sort_order\n' +
  'sample-2026-ar-math,story-1,passage,قصة سلمى,قرأت سلمى ٦٠ صفحة يوم الأحد و٤٥ صفحة يوم الاثنين.,1';

const EXAMPLE_QUESTIONS =
  'exam_key,path,type,stimulus_key,text,options,key,marks,criteria,model_answer,key_status,sort_order,access,marking_method\n' +
  'sample-2026-ar-math,1,mcq,story-1,كم صفحة قرأت سلمى في اليومين معاً؟,١٠٥||١١٥||١٣٥||١٥٠,أ,2,,,verified,1,trial,\n' +
  'sample-2026-ar-math,2,true_false,story-1,قرأت سلمى ١٠٥ صفحة في اليومين معاً.,,true,1,,,verified,2,paid,\n' +
  'sample-2026-ar-math,3,numeric,story-1,ما متوسط عدد الصفحات في اليوم؟ اكتب الرقم فقط.,,52.5,2,,,verified,3,paid,\n' +
  'sample-2026-ar-math,4,short_answer,story-1,اشرح كيف حسبت مجموع الصفحات.,,,5,طريقة الجمع صحيحة::2||النتيجة النهائية صحيحة::3,جمعت ٦٠ و٤٥ فحصلت على ١٠٥.,verified,4,paid,self_mark\n' +
  'sample-2026-ar-math,5,matrix_input,,إذا كانت A = [1 2; 3 4] فأوجد 2A (مصفوفة 2×2):,2x2,2||4;;6||8,3,,,verified,5,paid,\n' +
  'sample-2026-ar-math,6,truth_table,,أكمل جدول الحقيقة للعبارة A AND B:,A||B,0||0||0||1,2,,,verified,6,paid,\n' +
  'sample-2026-ar-math,7,fill_blank,story-1,أكمل الفراغات: قرأت سلمى ___ صفحة في اليوم الأول و___ صفحة في اليوم الثاني.,,٦٠||60;;٤٥||45,2,,,verified,7,paid,';

const COMMON_TYPES = `- container: حاوية بلا درجة وبلا مفتاح، لها أسئلة فرعية فقط.
- mcq: options مفصولة بـ || (خياران إلى عشرة، بلا تكرار)، وkey حرف واحد من أبجدية الورقة: أ، ب، ج، د، هـ، و، ز، ح، ط، ي (أو A–J في الأوراق الإنجليزية).
- multi_select: key حروف الإجابات الصحيحة مفصولة بـ ||.
- true_false: key هي true أو false.
- fill_blank: اكتب ___ (ثلاث شرطات سفلية أو أكثر) أو ......... (ثلاث نقاط أو أكثر) داخل text في موضع كل فراغ ليظهر حقل إدخال داخل الجملة نفسها؛ عدد العلامات يساوي عدد أجزاء المفتاح. كل فراغ مفصول بـ ;;، والبدائل داخل الفراغ الواحد مفصولة بـ ||.
- table_fill: ضع الجدول المرئي في text كصفوف أنابيب: سطر عناوين ثم صفوف بيانات، أول خلية في كل صف عنوان الصف (ثابت) والبقية خلايا يُكملها الطالب؛ افصل الخلايا بـ | والأسطر بسطر جديد داخل الحقل المقتبس. key على شكل row.column=value بترقيم يبدأ من 1 لأول صف بيانات وأول عمود قابل للتعبئة، والمدخلات مفصولة بـ ;;، والبدائل بـ ||.
- ordering: options مطلوبة، وkey ترتيب حروف الخيارات مفصولاً بـ ||.
- numeric: key رقماً فقط، مثل 52.5.
- math_expression: key تعبيراً نصياً مطابقاً.
- matching: حاوية بخيارات (القائمة الثانية)، وأبناؤها نوعهم matching_item فقط، ومفتاح كل عنصر حرف من خيارات الحاوية.
- diacritics: key النص المشكول كاملاً (تصحيح ذاتي).
- language_analysis: مثل fill_blank في المفتاح، ويحتاج criteria.
- matrix_input: options هي الأبعاد فقط بالشكل rowsxcols مثل 2x2، وkey صفوف المصفوفة مفصولة بـ ;; وكل صف خلاياه مفصولة بـ || (مثل 2||4;;6||8).
- truth_table: options أسماء متغيرات الإدخال مفصولة بـ || (مثل A||B)، وkey بت الخروج لكل صف من جدول الحقيقة مفصولة بـ || بترتيب الصفوف من أعلى (1 صحيح، 0 خطأ؛ لسطرين متغيرين: 0||0||0||1).
- short_answer و essay: بلا مفتاح؛ يحتاجان marks وcriteria وmodel_answer.`;

const COMMON_TYPES_EN = `- container: a heading with no marks and no key; it only holds children.
- mcq: options separated by || (two to ten, unique), key is one letter from the paper alphabet: أ, ب, ج, د, هـ, و, ز, ح, ط, ي (or A–J for English papers).
- multi_select: key is the correct letters separated by ||.
- true_false: key is true or false.
- fill_blank: write ___ (three or more underscores) or ......... (three or more dots) in text at each blank so the app renders an input inside the sentence itself; the number of markers must equal the number of key parts. Blanks are separated by ;; and alternatives inside one blank by ||.
- table_fill: put the visible grid in text as pipe rows: a header line then data rows whose first cell is a static row label and the rest are blanks the student fills; separate cells with | and rows with a newline inside the quoted field. key is row.column=value numbered from 1 at the first data row and first fillable column, entries separated by ;; and alternatives by ||.
- ordering: options are required; key is the correct option letters separated by ||.
- numeric: key is a number, e.g. 52.5.
- math_expression: key is the exact expression text.
- matching: a container with options (the right-hand list); its children must be matching_item rows and each item key is a letter from the container options.
- diacritics: key is the fully voweled text (self-marked).
- language_analysis: key works like fill_blank and criteria are required.
- matrix_input: options are the dimensions only, as rowsxcols such as 2x2; key is the matrix rows separated by ;; with each row's cells separated by || (e.g. 2||4;;6||8).
- truth_table: options are the input variable names separated by || (e.g. A||B); key is the output bit for each truth-table row, separated by ||, in top-to-bottom row order (1 true, 0 false; for two variables: 0||0||0||1).
- short_answer and essay: no key; they need marks, criteria and model_answer.`;

const AR_PROMPT = `أنت تساعدني في إعداد ورقة امتحان لمنصة «مذكرة». سألصق في النهاية نص الورقة؛ حوّله إلى ثلاثة ملفات CSV جاهزة للاستيراد، والتزم بالعقد التالي حرفياً.

قواعد الإخراج
- أخرج exams.csv و stimuli.csv و questions.csv فقط، كل ملف في كتلة كود مستقلة يسبقها اسم الملف.
- ترميز UTF-8، فواصل أسطر LF، وفاصل الحقول فاصلة.
- غلّف أي حقل يحتوي فاصلة أو علامة تنصيص أو سطراً جديداً بعلامتي تنصيص مزدوجة، وضاعف علامة التنصيص الداخلية ("") .
- لا تُدرج أسطراً جديدة داخل الخلية إلا في جدول table_fill أو نص القصيدة/المقطع، وحينها غلّف الحقل كاملاً بعلامتي تنصيص.
- الأرقام العربية أو اللاتينية مقبولة.
- لا تضف أعمدة غير مذكورة، ولا تستخدم أعمدة الصور إطلاقاً.
- لا تكتب شرحاً خارج كتل الملفات؛ سطر واحد قبل الملفات مسموح عند الضرورة فقط.
- حافظ على نص الأسئلة والقطع كما هو دون تلخيص أو تغيير في المعنى، وحافظ على ترقيم الورقة.

1) exams.csv — صف واحد لهذه الورقة
الأعمدة الإلزامية: ${EXAM_COLUMNS_REQUIRED}
الأعمدة الاختيارية: ${EXAM_COLUMNS_OPTIONAL}
- exam_key: معرّف ثابت فريد بالإنجليزية دون مسافات، مثل 2026-04_sec_arabic.
- exam_year: عدد صحيح بين 1900 و2200.
- session: مثل «الدور الأول». class_level: مثل «الشهادة السودانية».
- stream: التخصص أو اتركه فارغاً.
- language: ar أو en فقط.
- duration_minutes: عدد صحيح بين 1 و1440.
- total_marks: مجموع درجات الأسئلة النهائية (غير الحاويات)، وليس مجموع كل الصفوف.
- source: مصدر الورقة الحقيقي. إن لم أعطك مصدراً فاكتب: أُدخلت يدوياً بواسطة المالك.
- rights_note: بيان الحقوق؛ إن لم أعطك بياناً فاكتب: محتوى أُدخل بواسطة المالك.
- rights_status: public_declared أو licensed أو owner_authored أو blocked. استخدم owner_authored مع الملاحظة أعلاه.
- status: draft أو published أو blocked. استخدم draft دائماً ما لم أطلب النشر، فالنشر يتطلب مفاتيح غير مسودة.

2) stimuli.csv — القطع والنصوص المشتركة (اختياري)
الأعمدة الإلزامية: ${STIMULUS_COLUMNS_REQUIRED}
الأعمدة الاختيارية: ${STIMULUS_COLUMNS_OPTIONAL}
- stimulus_key: معرّف قصير فريد داخل الورقة، مثل story-1 أو poem-1.
- kind: passage أو poem أو quran أو table.
- text: النص كاملاً حرفياً دون اختصار أو تعديل.
- sort_order: عدد صحيح 0 أو أكثر.
- إن لم توجد قطعة مشتركة فأخرج الملف بالعناوين فقط.

3) questions.csv — الأسئلة
الأعمدة الإلزامية: ${QUESTION_COLUMNS_REQUIRED}
الأعمدة الاختيارية: ${QUESTION_COLUMNS_OPTIONAL}

- path: ترقيم هرمي بالنقاط، مثل 1 ثم 1.1 ثم 1.1.1. المسار فريد، والأب يجب أن يكون صفاً موجوداً في نفس الملف، وكل مقطع 40 حرفاً أو أقل.
- type: أحد الأنواع التالية:
${COMMON_TYPES}
- marks: درجة السؤال النهائي، نصف درجة على الأقل. الحاويات تُحسب درجاتها من أبنائها تلقائياً، فاترك marks فارغاً لها.
- مجموع marks للأسئلة النهائية يجب أن يساوي total_marks في exams.csv بالضبط.
- criteria: لكل معيار «نص::درجة»، والمعايير مفصولة بـ ||، ومجموعها يساوي marks. إلزامية في short_answer وessay وlanguage_analysis، وفي أي سؤال تصحيحه ai_rubric أو self_mark.
- model_answer: إلزامي للأسئلة المفتوحة short_answer وessay وlanguage_analysis وعند self_mark.
- key_status: official أو verified أو draft. استخدم verified ما لم أعطك حالة أخرى.
- access: trial أو paid أو free، والافتراضي paid. trial تعني معاينة مجانية تكشف الإجابة قبل الفتح.
- stimulus_key: يجب أن يطابق صفاً في stimuli.csv.
- topic_tags: مفاتيح مواضيع موجودة مسبقاً في المنصة، مفصولة بـ ; . اتركها فارغة إن لم أعطك المفاتيح.
- difficulty: عدد صحيح بين 1 و5 (الافتراضي 3).
- practice_eligible: true أو false.
- normalisation: أعلام مفصولة بفواصل، من: strip_tashkeel, unify_alef, strip_tatweel, collapse_spaces, ignore_case, ignore_punctuation, normalise_digits.
- accepted_alternatives: مقبولة فقط في fill_blank وnumeric وmath_expression وtrue_false، ومفصولة بـ ||. في fill_blank متعدد الفراغات ضع البدائل داخل كل فراغ بـ || ولا تستخدم هذا العمود.
- misconceptions: في mcq فقط، تسمية واحدة لكل خيار مفصولة بـ ||.
- marking_method: auto_exact أو auto_numeric أو auto_set أو ai_rubric أو self_mark. اتركه فارغاً ليُستنتج من النوع، وأي تصحيح auto يتطلب key.
- sort_order: عدد صحيح 0 أو أكثر، فريد بين الأسئلة التي لها الأب نفسه؛ رقّمها تسلسلياً.
- الحاويات container وmatching فقط يمكن أن يكون لها أبناء؛ والحاوية يجب أن يكون لها أبناء.
- لا تضع key في الحاويات. ولا تضع options في أنواع لا تقبل الخيارات، إلا أن تحمل بنية مرئية: أبعاد matrix_input أو متغيرات truth_table.
- الأسئلة المفتوحة short_answer وessay وlanguage_analysis: اترك key فارغاً.

قبل الإخراج تحقق بصمت من:
- مجموع درجات الأسئلة النهائية = total_marks.
- كل path فريد، وكل أب موجود.
- كل sort_order فريد بين الأشقاء.
- كل stimulus_key موجود، وكل key_status غير draft عند status=published.
- مجموع كل criteria = marks الخاصة بسؤالها.

هذا مثال مصغر صحيح بالكامل (ورقة من ١٥ درجة):
exams.csv
${EXAMPLE_EXAMS}

stimuli.csv
${EXAMPLE_STIMULI}

questions.csv
${EXAMPLE_QUESTIONS}

نص الورقة:
<<< الصق هنا نص ورقة الامتحان كاملاً، مع الدرجة الكلية والمدة والمصدر إن توفر. إن لم تذكر الدرجة الكلية فاحسبها من مجموع الأسئلة. >>>`;

const EN_PROMPT = `You are helping me prepare an exam paper for the Mothakira platform. I will paste the paper text at the end; convert it into three import-ready CSV files and follow this contract exactly.

Output rules
- Output only exams.csv, stimuli.csv and questions.csv, each in its own code block preceded by its file name.
- UTF-8, LF line endings, comma-separated fields.
- Quote any field that contains a comma, a double quote or a newline, and double any inner quote ("").
- Never put a newline inside a cell, except for a table_fill grid or poem/passage text; in those cases quote the whole field.
- Arabic or Latin digits are both accepted.
- Do not add columns beyond those listed, and never use image columns.
- Write no prose outside the file blocks; one line before the files is allowed only if truly needed.
- Keep question and passage wording verbatim, do not summarise or change meaning, and keep the paper numbering.

1) exams.csv — one row for this paper
Required columns: ${EXAM_COLUMNS_REQUIRED}
Optional columns: ${EXAM_COLUMNS_OPTIONAL}
- exam_key: a stable unique ASCII identifier without spaces, e.g. 2026-04_sec_arabic.
- exam_year: whole number between 1900 and 2200.
- session: e.g. "First session". class_level: e.g. "Secondary Certificate".
- stream: the stream, or leave it empty.
- language: ar or en only.
- duration_minutes: whole number between 1 and 1440.
- total_marks: the sum of the leaf questions (not containers), not the sum of every row.
- source: the real source. If I give none, write: Entered manually by the owner.
- rights_note: the rights statement; if I give none, write: Content entered by the owner.
- rights_status: public_declared, licensed, owner_authored or blocked. Use owner_authored with the note above.
- status: draft, published or blocked. Always use draft unless I ask to publish, because publishing requires non-draft keys.

2) stimuli.csv — shared passages (optional)
Required columns: ${STIMULUS_COLUMNS_REQUIRED}
Optional columns: ${STIMULUS_COLUMNS_OPTIONAL}
- stimulus_key: a short identifier unique inside the paper, e.g. story-1 or poem-1.
- kind: passage, poem, quran or table.
- text: the full text verbatim, never shortened or edited.
- sort_order: whole number, 0 or more.
- If there is no shared passage, output the header row only.

3) questions.csv — the questions
Required columns: ${QUESTION_COLUMNS_REQUIRED}
Optional columns: ${QUESTION_COLUMNS_OPTIONAL}

- path: dotted hierarchy, e.g. 1, then 1.1, then 1.1.1. Each path is unique, every parent must be a row in the same file, and each segment is at most 40 characters.
- type: one of the following:
${COMMON_TYPES_EN}
- marks: the leaf question marks, at least 0.5. Container marks are derived from their children, so leave marks empty for containers.
- The marks of all leaf questions must equal total_marks in exams.csv exactly.
- criteria: each criterion is "text::marks", criteria are separated by ||, and they sum to marks. Required for short_answer, essay and language_analysis, and for any question marked ai_rubric or self_mark.
- model_answer: required for open questions (short_answer, essay, language_analysis) and for self_mark.
- key_status: official, verified or draft. Use verified unless I give another status.
- access: trial, paid or free; the default is paid. trial is a free preview that reveals its answer before unlock.
- stimulus_key: must match a row in stimuli.csv.
- topic_tags: keys of topics that already exist in the platform, separated by ; . Leave empty if I give no keys.
- difficulty: whole number between 1 and 5 (default 3).
- practice_eligible: true or false.
- normalisation: comma-separated flags from strip_tashkeel, unify_alef, strip_tatweel, collapse_spaces, ignore_case, ignore_punctuation, normalise_digits.
- accepted_alternatives: allowed only for fill_blank, numeric, math_expression and true_false, separated by ||. For a fill_blank with several blanks put the alternatives inside each blank with || and do not use this column.
- misconceptions: mcq only, one label per option separated by ||.
- marking_method: auto_exact, auto_numeric, auto_set, ai_rubric or self_mark. Leave it empty to derive it from the type; any auto marking needs a key.
- sort_order: whole number, 0 or more, unique among questions with the same parent; number them sequentially.
- Only container and matching may have children, and a container must have children.
- Never put a key on a container, and never put options on a type that does not take them, except when options carry visible structure: matrix_input dimensions or truth_table input variables.
- For short_answer, essay and language_analysis leave key empty.

Before output, silently check:
- Leaf marks add up to total_marks.
- Every path is unique and every parent exists.
- Every sort_order is unique among siblings.
- Every stimulus_key exists, and no key_status is draft when status is published.
- Each criteria list adds up to that question's marks.

A small, fully valid example (a 15-mark paper):
exams.csv
${EXAMPLE_EXAMS}

stimuli.csv
${EXAMPLE_STIMULI}

questions.csv
${EXAMPLE_QUESTIONS}

Paper text:
<<< Paste the full exam paper here, with the total marks, duration and source if available. If the total marks are missing, compute them from the questions. >>>`;

export function buildImportPrompt(language) {
  return language === 'en' ? EN_PROMPT : AR_PROMPT;
}

export async function copyText(text) {
  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch {
    /* fall through to the selection-based copy */
  }
  const area = document.createElement('textarea');
  area.value = text;
  area.setAttribute('readonly', '');
  area.style.position = 'fixed';
  area.style.top = '-1000px';
  document.body.appendChild(area);
  area.select();
  try {
    return document.execCommand('copy');
  } catch {
    return false;
  } finally {
    document.body.removeChild(area);
  }
}
