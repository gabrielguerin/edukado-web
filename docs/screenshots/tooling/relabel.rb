# frozen_string_literal: true

# Rewrites ONLY the nonsense text fields that db/seeds.rb fills with Faker data,
# so screenshots read as a credible French student platform.
#
# Run inside the container with `rails runner`. It issues UPDATEs against the
# local development database only; db/seeds.rb and every application file stay
# untouched. Never point this at anything you care about.
#
# Left exactly as seeded: users' names/emails/genders, the 10 institutions,
# the 8 categories, the 7 academic years, levels (integers 1-10, already fine),
# and the 10 CSV-imported finance documents (already realistic).

# Ruby 2.6: no endless method definitions.
def say(msg)
  puts "[relabel] #{msg}"
end

# ---------------------------------------------------------------------------
# Content pools. Indexed assignment keeps the result reproducible across runs.
# ---------------------------------------------------------------------------

SUBJECTS = [
  'Économie', 'Mathématiques', 'Droit', 'Histoire', 'Sociologie',
  'Science politique', 'Philosophie', 'Comptabilité', 'Finance', 'Marketing',
  'Management', 'Statistiques', 'Informatique', 'Physique', 'Chimie',
  'Biologie', 'Géographie', 'Anglais', 'Espagnol', 'Allemand',
  'Psychologie', 'Anthropologie', 'Linguistique', 'Littérature',
  'Relations internationales', 'Démographie', 'Géopolitique',
  'Économétrie', 'Logistique', 'Communication'
].freeze

COURSES = [
  'Microéconomie', 'Macroéconomie', 'Comptabilité générale', 'Analyse financière',
  'Statistiques descriptives', 'Probabilités', 'Algèbre linéaire',
  'Droit constitutionnel', 'Droit administratif', 'Droit des obligations',
  'Histoire contemporaine', 'Histoire des idées politiques', 'Sociologie générale',
  'Méthodes quantitatives', 'Économétrie appliquée', 'Marketing stratégique',
  'Comportement du consommateur', 'Gestion des ressources humaines',
  'Contrôle de gestion', 'Fiscalité des entreprises', 'Relations internationales',
  'Institutions européennes', 'Politique comparée', 'Économie monétaire',
  'Finance de marché', 'Gestion de portefeuille', "Systèmes d'information",
  'Bases de données', 'Algorithmique', 'Anglais des affaires',
  'Espagnol juridique', 'Philosophie politique', 'Épistémologie',
  'Psychologie cognitive', 'Démographie', 'Géopolitique du monde contemporain',
  'Économie du développement', 'Commerce international', 'Négociation',
  'Communication professionnelle'
].freeze

TAGS = %w[
  économie finance comptabilité droit statistiques marketing management
  histoire sociologie méthodologie révisions partiel fiches td
  annales corrigé licence master examen dissertation résumé synthèse
  bibliographie tableur modélisation macroéconomie microéconomie fiscalité
  audit économétrie probabilités algèbre informatique anglais espagnol
  philosophie géopolitique démographie logistique négociation communication
  psychologie linguistique littérature géographie physique chimie biologie
  amphi semestre1 semestre2
].freeze

# Document titles are built as "<kind> — <topic>", which mirrors how French
# students actually name shared coursework.
DOC_KINDS = [
  'CM 1', 'CM 2', 'CM 3', 'TD 1', 'TD 2', 'TD 3', 'TD 4',
  'Fiche de révision', 'Résumé de cours', 'Plan détaillé',
  'Exercices corrigés', 'Synthèse', 'Notes de cours', 'Méthodologie',
  'Annales 2019', 'Annales 2020', 'Dissertation', 'Étude de cas',
  'Tableau récapitulatif', 'Corrigé du partiel'
].freeze

DOC_TOPICS = [
  "l'élasticité de la demande", 'la concurrence imparfaite', 'le monopole naturel',
  "l'équilibre général", 'la politique monétaire', "l'inflation et le chômage",
  'la croissance endogène', 'le bilan comptable', 'le compte de résultat',
  "l'analyse des flux de trésorerie", 'la valeur actuelle nette',
  'le coût moyen pondéré du capital', 'la structure du capital',
  'les tests de significativité', 'la régression linéaire multiple',
  'la loi normale', "l'échantillonnage", 'la hiérarchie des normes',
  'le contrôle de constitutionnalité', 'la séparation des pouvoirs',
  'la responsabilité administrative', 'la formation du contrat',
  "les vices du consentement", 'la Troisième République',
  'la construction européenne', 'la guerre froide', 'la décolonisation',
  'les classes sociales', 'la mobilité sociale', "l'individualisme méthodologique",
  'le contrat social', 'la souveraineté nationale', 'la segmentation du marché',
  'le mix marketing', "le parcours d'achat", 'la motivation au travail',
  'le tableau de bord prospectif', "l'impôt sur les sociétés",
  'la TVA intracommunautaire', 'les organisations internationales',
  'la Commission européenne', 'les régimes politiques comparés',
  'le taux de change', 'les produits dérivés', 'la diversification du risque',
  'la modélisation relationnelle', 'la complexité algorithmique',
  'la transition démographique', 'les théories du développement',
  'la négociation distributive'
].freeze

DESCRIPTIONS = [
  'Notes prises en amphi et relues avec le manuel. Couvre les quatre premiers chapitres.',
  'Fiche rédigée pour préparer le partiel de fin de semestre. Définitions et schémas inclus.',
  'Corrigé complet, avec le détail des calculs intermédiaires.',
  'Résumé de dix pages ramené à trois. Idéal pour une révision de dernière minute.',
  'Support distribué en cours, annoté pendant la séance.',
  'Plan détaillé avec introduction et conclusion rédigées, plus la bibliographie.',
  'Exercices du fascicule avec la méthode de résolution pas à pas.',
  'Synthèse des lectures obligatoires du semestre.',
  'Sujet tombé l’an dernier, avec ma proposition de corrigé.',
  'Tableau comparatif que j’ai construit pour retenir les distinctions clés.',
  'Version relue et corrigée après les remarques du chargé de TD.',
  'Notes complétées avec les références citées en cours.'
].freeze

COMMENTS = [
  'Merci beaucoup, ça m’a vraiment aidé pour le partiel !',
  'Est-ce que tu as aussi le corrigé du TD suivant ?',
  'Très clair, surtout la partie sur les définitions.',
  'Attention, il manque la dernière question de l’exercice 3.',
  'Exactement ce que je cherchais, merci du partage.',
  'Le plan est bien construit, je m’en suis inspiré pour ma dissertation.',
  'Petite erreur page 2 dans le calcul, sinon parfait.',
  'Tu as pris le cours avec quel enseignant ?',
  'Ça complète bien mes propres notes, merci !',
  'Je confirme que ce sujet est tombé cette année aussi.',
  'Super synthèse, beaucoup plus lisible que le poly officiel.',
  'Quelqu’un aurait la bibliographie complète ?',
  'Merci, j’ai enfin compris la démonstration.',
  'Est-ce que c’est à jour avec le programme de cette année ?',
  'Très utile pour réviser dans le train, merci.',
  'J’ajoute que le chapitre 5 est aussi au programme.',
  'Excellent, je le partage à mon groupe de TD.',
  'Les schémas sont vraiment bien faits.',
  'Il y a une coquille dans le titre de la partie II.',
  'Merci ! Tu comptes mettre en ligne la suite ?'
].freeze

BIOS = [
  'Étudiant en licence d’économie, je partage mes fiches de révision.',
  'En master de droit public. J’échange surtout des annales corrigées.',
  'Passionné de statistiques, je mets en ligne mes exercices corrigés.',
  'Étudiante en science politique, spécialité relations internationales.',
  'Je prends des notes très détaillées en amphi et je les partage volontiers.',
  'En troisième année de gestion, parcours contrôle de gestion.',
  'Étudiante en sociologie. Je cherche surtout des méthodologies de dissertation.',
  'Master de finance. Je partage mes modèles de valorisation.',
  'Je redouble ma L2, donc j’ai pas mal de ressources de l’an dernier.',
  'Étudiant en double licence droit-économie. Beaucoup de fiches à échanger.',
  'En école de management, échange international en cours.',
  'J’aime bien refaire les schémas du cours au propre, autant que ça serve.',
  'Étudiante en histoire contemporaine, mémoire sur la construction européenne.',
  'En prépa intégrée. Je partage surtout des exercices de maths.',
  'Master d’économétrie appliquée. Disponible pour relire des travaux.'
].freeze

BLOG_TITLES = [
  'Cinq méthodes pour réviser efficacement avant les partiels',
  'Comment structurer une dissertation en sciences sociales',
  'Bien prendre ses notes en amphi : ce qui marche vraiment',
  'Réussir sa note de synthèse : la méthode pas à pas',
  'Organiser son semestre sans se laisser déborder',
  'Pourquoi partager ses cours vous fait progresser',
  'Les erreurs les plus fréquentes en analyse financière',
  'Travailler en groupe de TD : bonnes pratiques',
  'Choisir sa spécialité en master : quelques repères',
  'Lire un article académique sans y passer la nuit',
  'Préparer un oral : gérer le fond et le trac',
  'Construire une bibliographie qui tient debout',
  'Réviser les statistiques quand on n’aime pas les maths',
  'Ce que les correcteurs attendent vraiment d’une copie',
  'Gérer la charge de travail en fin de semestre'
].freeze

BLOG_BODY = [
  'La révision efficace repose moins sur le temps passé que sur la manière dont ' \
  'on sollicite sa mémoire. Relire ses notes donne une impression de maîtrise qui ' \
  'résiste mal à l’épreuve de la copie.',
  'La première étape consiste à reformuler le cours sans le regarder. C’est ' \
  'inconfortable, et c’est précisément ce qui rend l’exercice utile : on ' \
  'identifie immédiatement ce qui n’est pas acquis.',
  'Vient ensuite le travail sur les annales. Un sujet traité en conditions ' \
  'réelles apprend davantage que trois relectures passives, parce qu’il oblige ' \
  'à choisir, à hiérarchiser et à conclure.',
  'Enfin, expliquer une notion à quelqu’un d’autre reste le meilleur test. Si ' \
  'l’explication tient en trois phrases claires, la notion est comprise. Sinon, ' \
  'il reste du travail — et on sait exactement où.'
].freeze

# ---------------------------------------------------------------------------
# The 10 CSV-imported documents already have realistic titles; leave them be.
# ---------------------------------------------------------------------------
CSV_TITLES = [
  'Financial Statement Analysis - In Classroom Slides',
  'Financial Statement Analysis',
  'Time Value of Money - Annuities and Perpetuities',
  'Time Value of Money - Interest rates',
  'Time Value of Money',
  'Project Valuation - Investment decision rules',
  'Project Valuation - Sensitivity and Scenario Analysis',
  'Valuation - Cash-flows',
  'Capital Structure',
  'Cost of Capital - CAPM'
].freeze

ActiveRecord::Base.logger = nil

# --- Subjects ---------------------------------------------------------------
Subject.order(:id).each_with_index do |s, i|
  s.update_columns(name: SUBJECTS[i % SUBJECTS.size])
end
say "subjects: #{Subject.count} renamed"

# --- Courses ----------------------------------------------------------------
Course.order(:id).each_with_index do |c, i|
  c.update_columns(name: COURSES[i % COURSES.size])
end
say "courses: #{Course.count} renamed"

# --- Tags (stored lowercase by the model's before_save) ---------------------
# `tags.slug` is uniquely indexed, and the CSV import already created tags whose
# names overlap this list ("finance"). Renaming in place would collide with a row
# that has not been renamed yet, so park every slug on a unique temporary value
# first, then assign the final names.
tags = Tag.order(:id).to_a
tags.each { |t| t.update_columns(title: "tmp-#{t.id}", slug: "tmp-#{t.id}") }

# Guarantee as many distinct names as there are tags.
names = TAGS.dup
names << "#{TAGS[names.size % TAGS.size]}-#{names.size}" while names.size < tags.size

tags.each_with_index do |t, i|
  t.update_columns(title: names[i], slug: names[i].parameterize)
end
say "tags: #{tags.size} renamed"

# --- Users' bios ------------------------------------------------------------
User.order(:id).each_with_index do |u, i|
  u.update_columns(description: BIOS[i % BIOS.size])
end
say "users: #{User.count} bios rewritten"

# --- Documents --------------------------------------------------------------
# Build unique "<kind> — <topic>" pairs so no two documents collide.
pairs = DOC_KINDS.product(DOC_TOPICS).shuffle(random: Random.new(42))
i = 0
renamed = 0
kept = 0
Post.order(:id).each do |p|
  # The ten CSV documents already have realistic titles, so keep those — but
  # their CSV `description` column is English filler, which shows on the
  # document page. Rewrite the description only.
  if CSV_TITLES.include?(p.title)
    kept += 1
    p.update_columns(description: DESCRIPTIONS[kept % DESCRIPTIONS.size])
    next
  end

  kind, topic = pairs[i % pairs.size]
  i += 1
  # Capitalise the topic so the title reads properly on the document page,
  # where it is displayed verbatim rather than upcased by CSS.
  title = "#{kind} — #{topic[0].upcase}#{topic[1..-1]}"
  # friendly_id only generates a slug when it is nil, so clear it to force a
  # slug that matches the new title.
  p.update_columns(
    title: title,
    description: DESCRIPTIONS[i % DESCRIPTIONS.size],
    slug: title.parameterize
  )

  # Every generated post is seeded with the same sample attachment (SEO.pdf),
  # whose name is shown on the document page. Rename the blob to match the
  # document so the file card is coherent. Only the filename column changes;
  # the stored object is untouched.
  if p.file.attached?
    p.file.blob.update_columns(filename: "#{title.tr('—', '-')}.pdf")
  end
  renamed += 1
end
say "documents: #{renamed} renamed, #{kept} CSV titles kept with new descriptions"

# --- Comments ---------------------------------------------------------------
Comment.order(:id).each_with_index do |c, i|
  c.update_columns(description: COMMENTS[i % COMMENTS.size])
end
say "comments: #{Comment.count} rewritten"

# --- Blogs ------------------------------------------------------------------
Blog.order(:id).each_with_index do |b, i|
  title = "#{BLOG_TITLES[i % BLOG_TITLES.size]}#{i >= BLOG_TITLES.size ? " (#{i / BLOG_TITLES.size + 1})" : ''}"
  cols = { title: title, slug: title.parameterize }
  cols[:description] = DESCRIPTIONS[i % DESCRIPTIONS.size] if b.respond_to?(:description)
  b.update_columns(cols)
  # `body` may be a plain column or an Action Text association.
  if b.respond_to?(:body=)
    begin
      b.update!(body: BLOG_BODY.join("\n\n"))
    rescue StandardError => e
      say "  blog #{b.id} body skipped: #{e.class}"
    end
  end
end
say "blogs: #{Blog.count} rewritten"

# --- Reindex every searchkick model so search screenshots match the new text -
say 'reindexing elasticsearch...'
[Post, User, Tag, Course, Subject, Category, Group, Level].each do |m|
  m.reindex
  say "  #{m.name} reindexed"
end

say 'DONE'
