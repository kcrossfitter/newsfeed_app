# newsfeed_app

Table, View, Functions, Triggers and RLS
1. profiles table 
```-- profiles 테이블 생성 
CREATE TABLE public.profiles ( 
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE, 
  username TEXT UNIQUE NOT NULL, 
  avatar_url TEXT, 
  role TEXT NOT NULL DEFAULT 'user', 
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW() 
); 

-- profiles 테이블에 대한 updated_at 트리거 적용 
CREATE TRIGGER set_profiles_updated_at 
BEFORE UPDATE ON public.profiles 
FOR EACH ROW 
EXECUTE PROCEDURE public.trigger_set_timestamp(); 

-- RLS 활성화 (정책은 추후 정의) 
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
```

2. newsfeeds table
```
-- newsfeeds 테이블 생성 
CREATE TABLE public.newsfeeds ( 
  id UUID PRIMARY KEY, 
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE, 
  title TEXT NOT NULL, 
  content TEXT NOT NULL, 
  image_url TEXT, 
  likes_count INT NOT NULL DEFAULT 0, 
  comments_count INT NOT NULL DEFAULT 0, 
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW() 
); 

-- newsfeeds 테이블에 대한 updated_at 트리거 적용 
CREATE TRIGGER set_newsfeeds_updated_at 
BEFORE UPDATE ON public.newsfeeds 
FOR EACH ROW 
EXECUTE PROCEDURE public.trigger_set_timestamp(); 

-- RLS 활성화 (정책은 추후 정의) 
ALTER TABLE public.newsfeeds ENABLE ROW LEVEL SECURITY; 

-- 검색 성능을 위한 인덱스 (선택적이지만 권장) 
CREATE INDEX idx_newsfeeds_author_id ON public.newsfeeds(author_id); 
CREATE INDEX idx_newsfeeds_created_at ON public.newsfeeds(created_at DESC); 
```

3. comments table
```
-- comments 테이블 생성 
CREATE TABLE public.comments ( 
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
  post_id UUID NOT NULL REFERENCES public.newsfeeds(id) ON DELETE CASCADE, 
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE, 
  content TEXT NOT NULL, 
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW() 
); 

-- comments 테이블에 대한 updated_at 트리거 적용 
CREATE TRIGGER set_comments_updated_at 
BEFORE UPDATE ON public.comments 
FOR EACH ROW 
EXECUTE PROCEDURE public.trigger_set_timestamp(); 

-- RLS 활성화 (정책은 추후 정의) 
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY; 

-- 댓글 조회를 위한 인덱스 (선택적이지만 권장) 
CREATE INDEX idx_comments_post_id ON public.comments(post_id); 
CREATE INDEX idx_comments_user_id ON public.comments(user_id); 
```

4. likes table 
```
-- likes 테이블 생성
CREATE TABLE public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- 또는 BIGSERIAL PRIMARY KEY
  post_id UUID NOT NULL REFERENCES public.newsfeeds(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_like UNIQUE (post_id, user_id)
);

-- RLS 활성화 (정책은 추후 정의)
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- 좋아요 조회를 위한 인덱스 (선택적이지만 권장)
CREATE INDEX idx_likes_post_id ON public.likes(post_id);
CREATE INDEX idx_likes_user_id ON public.likes(user_id);
```

5. newsfeed display view 
```
CREATE OR REPLACE VIEW public.newsfeed_display_view AS 
SELECT 
  n.id AS post_id, -- 게시물 ID 
  n.title, -- 게시물 제목 
  n.content, -- 게시물 내용 
  n.image_url, -- 게시물 이미지 URL 
  n.created_at AS post_created_at, -- 게시물 생성 시각 
  n.updated_at AS post_updated_at, -- 게시물 수정 시각 
  n.author_id, -- 작성자 ID 
  p.username AS author_username, -- 작성자 닉네임 
  p.avatar_url AS author_avatar_url, -- 작성자 프로필 이미지 URL 
  p.role AS author_role, -- 작성자 역할 
  n.likes_count, -- 좋아요 수 (newsfeeds 테이블의 컬럼) 
  n.comments_count, -- 댓글 수 (newsfeeds 테이블의 컬럼) 
  EXISTS( 
    SELECT 1 
    FROM public.likes l_user 
    WHERE l_user.post_id = n.id AND l_user.user_id = auth.uid() 
  ) AS current_user_liked -- 현재 로그인한 사용자의 '좋아요' 여부 
FROM 
  public.newsfeeds n 
JOIN 
  public.profiles p ON n.author_id = p.id; 
```

6. Comment Display View
```
CREATE OR REPLACE VIEW public.comment_display_view AS
SELECT
  c.id,
  c.post_id,
  c.content,
  c.created_at,
  c.user_id AS author_id,
  p.username AS author_username,
  p.avatar_url AS author_avatar_url
FROM
  public.comments c
  JOIN public.profiles p ON c.user_id = p.id
ORDER BY
  c.created_at DESC; -- 최신 댓글이 위로 오도록 정렬
```

7. updated_at trigger function 
```
-- updated_at 컬럼을 현재 시간으로 설정하는 트리거 함수 
CREATE OR REPLACE FUNCTION public.trigger_set_timestamp() 
RETURNS TRIGGER AS $$ 
BEGIN 
  NEW.updated_at = NOW(); 
  RETURN NEW; 
END; 
$$ LANGUAGE plpgsql; 
```

8. profiles table trigger 
```
-- 새로운 사용자를 위한 프로필 자동 생성 함수 
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$ 
BEGIN 
  INSERT INTO public.profiles (id, username, role) 
  VALUES ( 
  NEW.id, 
  NEW.raw_user_meta_data->>'username', 
  COALESCE(NEW.raw_user_meta_data->>'role', 'user') 
  ); 
RETURN NEW; 
END; 
$$; 

-- auth.users 테이블에 사용자가 추가된 후 실행될 트리거 
CREATE TRIGGER on_auth_user_created 
AFTER INSERT ON auth.users 
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
``` 

9. update likes count trigger 
```
CREATE OR REPLACE FUNCTION public.update_likes_count() 
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER -- newsfeeds 테이블을 수정할 권한 필요 
AS $$ 
BEGIN 
  IF (TG_OP = 'INSERT') THEN 
    UPDATE public.newsfeeds 
    SET likes_count = likes_count + 1 
    WHERE id = NEW.post_id; 
    RETURN NEW; 
  ELSIF (TG_OP = 'DELETE') THEN 
    UPDATE public.newsfeeds 
    SET likes_count = likes_count - 1 
    WHERE id = OLD.post_id; 
    -- likes_count가 음수가 되지 않도록 보정 (선택적) 
    -- UPDATE public.newsfeeds 
    -- SET likes_count = GREATEST(0, likes_count - 1) 
    -- WHERE id = OLD.post_id; 
    RETURN OLD; 
  END IF; 
  RETURN NULL; -- UPDATE의 경우엔 실행되지 않도록 설정 
END; 
$$; 

CREATE OR REPLACE TRIGGER on_like_change_update_newsfeed_likes_count 
AFTER INSERT OR DELETE ON public.likes 
FOR EACH ROW EXECUTE PROCEDURE public.update_likes_count(); 
```

10. update comment count trigger 
```
CREATE OR REPLACE FUNCTION public.update_comments_count() 
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER -- newsfeeds 테이블을 수정할 권한 필요 
AS $$ 
BEGIN 
  IF (TG_OP = 'INSERT') THEN 
    UPDATE public.newsfeeds 
    SET comments_count = comments_count + 1 
    WHERE id = NEW.post_id; 
    RETURN NEW; 
  ELSIF (TG_OP = 'DELETE') THEN 
    UPDATE public.newsfeeds 
    SET comments_count = comments_count - 1 
    WHERE id = OLD.post_id; 
    -- comments_count가 음수가 되지 않도록 보정 (선택적) 
    -- UPDATE public.newsfeeds 
    -- SET comments_count = GREATEST(0, comments_count - 1) 
    -- WHERE id = OLD.post_id; 
    RETURN OLD; 
  END IF; 
  RETURN NULL; -- UPDATE의 경우엔 실행되지 않도록 설정 
END; 
$$; 

CREATE OR REPLACE TRIGGER on_comment_change_update_newsfeed_comments_count 
AFTER INSERT OR DELETE ON public.comments 
FOR EACH ROW EXECUTE PROCEDURE public.update_comments_count(); 
```

11. handle post likes function 
```
CREATE OR REPLACE FUNCTION public.handle_like(p_post_id UUID) 
RETURNS JSON -- 또는 TEXT, BOOLEAN 등 결과 타입 명시 
LANGUAGE plpgsql 
-- SECURITY INVOKER는 기본값이지만, RLS 정책이 likes 테이블에 잘 적용되어 있어야 함 
AS $$ 
DECLARE 
  current_user_id UUID := auth.uid(); 
  like_exists BOOLEAN; 
  new_like_count INT; 
BEGIN 
  -- 현재 사용자가 이미 좋아요를 눌렀는지 확인 
  SELECT EXISTS ( 
    SELECT 1 FROM public.likes 
    WHERE post_id = p_post_id AND user_id = current_user_id 
  ) INTO like_exists; 

  IF like_exists THEN 
    -- 이미 좋아요를 눌렀으면 삭제 (좋아요 취소) 
    DELETE FROM public.likes 
    WHERE post_id = p_post_id AND user_id = current_user_id; 
  ELSE 
    -- 좋아요를 누르지 않았으면 추가 
    INSERT INTO public.likes (post_id, user_id) 
    VALUES (p_post_id, current_user_id); 
  END IF; 

  -- 변경 후 최신 좋아요 수 조회 (newsfeeds 테이블에서 직접 읽어옴) 
  SELECT likes_count INTO new_like_count 
  FROM public.newsfeeds 
  WHERE id = p_post_id; 

  RETURN json_build_object( 
    'success', true, 
    'liked', NOT like_exists, -- 이전 상태의 반대 (새로운 좋아요 상태) 
    'likes_count', new_like_count 
  ); 
  EXCEPTION 
    WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'message', SQLERRM); 
END; 
$$; 
```

12. search newsfeed function 
```
CREATE OR REPLACE FUNCTION public.search_newsfeeds(p_search_query TEXT) 
RETURNS SETOF public.newsfeed_display_view -- 이전에 정의한 View를 반환 타입으로 사용 
LANGUAGE plpgsql 
AS $$ 
BEGIN 
  RETURN QUERY 
  SELECT * 
  FROM public.newsfeed_display_view 
  WHERE 
    -- PostgreSQL Full-Text Search 사용 (언어: english) 
    -- 'pg_catalog.english'는 PostgreSQL에 내장된 영어 텍스트 검색 구성입니다. 
    to_tsvector('pg_catalog.english', title || ' ' || content) @@ plainto_tsquery('pg_catalog.english', p_search_query) 
  ORDER BY post_created_at DESC; -- 최신순 정렬 등 추가 가능 
END; 
$$; 
```

13. index for full text search on newsfeeds 
```
CREATE INDEX newsfeeds_fts_idx 
ON public.newsfeeds 
USING GIN (to_tsvector('pg_catalog.english', title || ' ' || content)); 
```

14. get_user_role function 
```
CREATE OR REPLACE FUNCTION public.get_user_role(p_user_id UUID) 
RETURNS TEXT 
LANGUAGE sql 
STABLE -- 데이터 변경 없이 조회만 하므로 STABLE 
SECURITY INVOKER -- 호출자의 권한으로 실행 (profiles 테이블에 대한 SELECT 권한 필요) 
AS $$ 
  SELECT role FROM public.profiles WHERE id = p_user_id; 
$$; 
```

15. check admin status function 
```
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID) 
RETURNS BOOLEAN 
LANGUAGE sql 
STABLE 
SECURITY INVOKER 
AS $$ 
  SELECT EXISTS ( 
  SELECT 1 FROM public.profiles 
  WHERE id = p_user_id AND role = 'admin' 
  ); 
$$; 
```

16. profile access control policy 
```
-- SELECT Policy
-- 정책: 인증된 사용자는 다른 사용자의 profile을 볼 수 있음
CREATE POLICY "Allow authenticated users to read all profile information"
ON public.profiles
FOR SELECT
TO authenticated -- 'authenticated' 역할의 사용자에게 적용
USING (true);

-- UPDATE Policy
-- 정책 1: 사용자는 자신의 프로필을 수정할 수 있습니다.
CREATE POLICY "User can target own profile for update"
ON public.profiles
FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = id)
WITH CHECK ((SELECT auth.uid()) = id);

-- 정책 2: 관리자는 모든 프로필을 수정할 수 있습니다.
CREATE POLICY "Admin can target any profile for update"
ON public.profiles
FOR UPDATE
TO authenticated
USING (public.get_user_role((SELECT auth.uid())) = 'admin')
WITH CHECK (true); -- 이 정책 자체는 어떤 컬럼이든 변경 가능하게 하지만, 다음 단계에서 컬럼 권한으로 제한

-- 확실하게 권한 차단
REVOKE UPDATE ON public.profiles FROM authenticated;
REVOKE UPDATE (role) ON public.profiles FROM authenticated;

-- 필요한 컬럼만 다시 부여
GRANT UPDATE (username, avatar_url) ON public.profiles TO authenticated; 
```

17.  newsfeed access control policy 
```
-- SELECT Policy
-- 정책 1: 인증된 사용자는 모든 뉴스피드를 조회할 수 있습니다.
CREATE POLICY "Allow authenticated users to read all newsfeeds"
ON public.newsfeeds
FOR SELECT
TO authenticated -- 'authenticated' 역할에게 적용
USING (true);

-- INSERT Policy
-- 정책 1: 관리자만 뉴스피드를 생성할 수 있으며, author_id는 본인이어야 합니다.
CREATE POLICY "Allow admin to create newsfeeds"
ON public.newsfeeds
FOR INSERT
TO authenticated -- INSERT를 시도할 수 있는 역할 (인증된 사용자)
WITH CHECK (
  public.get_user_role((SELECT auth.uid())) = 'admin' AND
  author_id = (SELECT auth.uid())
);

-- UPDATE Policy
-- 정책 1: 관리자만 뉴스피드를 수정할 수 있습니다.
CREATE POLICY "Allow admin to update own newsfeeds"
ON public.newsfeeds
FOR UPDATE
TO authenticated -- UPDATE를 시도할 수 있는 역할
USING ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin')
WITH CHECK ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin');

-- DELETE Policy
-- 정책 1: 관리자만 뉴스피드를 삭제할 수 있습니다.
CREATE POLICY "Allow admin to delete own newsfeeds"
ON public.newsfeeds
FOR DELETE
TO authenticated -- DELETE를 시도할 수 있는 역할
USING ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin'); 
```

17. comment access control policy 
```
-- SELECT Policy
-- 정책 1: 인증된 사용자는 모든 댓글을 조회할 수 있습니다.
CREATE POLICY "Allow authenticated users to read all comments"
ON public.comments
FOR SELECT
TO authenticated -- 'authenticated' 역할에게 적용
USING (true);

-- INSERT Policy
-- 정책 1: 인증된 사용자는 댓글을 생성할 수 있으며, user_id는 본인이어야 합니다.
CREATE POLICY "Allow authenticated users to create comments"
ON public.comments
FOR INSERT
TO authenticated -- INSERT를 시도할 수 있는 역할 (인증된 사용자)
WITH CHECK (user_id = (SELECT auth.uid()));

-- UPDATE Policy
-- 정책 1: 사용자는 자신의 댓글만 수정할 수 있습니다.
CREATE POLICY "Allow users to update their own comments"
ON public.comments
FOR UPDATE
TO authenticated -- UPDATE를 시도할 수 있는 역할
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

-- DELETE Policy
-- 정책 1: 사용자는 자신의 댓글을 삭제할 수 있습니다.
CREATE POLICY "Allow users to delete their own comments"
ON public.comments
FOR DELETE
TO authenticated -- DELETE를 시도할 수 있는 역할
USING (user_id = (SELECT auth.uid()));

-- 정책 2: 관리자는 모든 댓글을 삭제할 수 있습니다.
CREATE POLICY "Allow admin to delete any comments"
ON public.comments
FOR DELETE
TO authenticated -- DELETE를 시도할 수 있는 역할 (관리자도 인증된 사용자임)
USING (public.get_user_role((SELECT auth.uid())) = 'admin');
 
```

18. likes management policy 
```
-- SELECT Policy
-- 정책 1: 인증된 사용자는 모든 '좋아요' 정보를 조회할 수 있습니다.
CREATE POLICY "Allow authenticated users to read all likes"
ON public.likes
FOR SELECT
TO authenticated -- 'authenticated' 역할에게 적용
USING (true);

-- INSERT Policy
-- 정책 1: 인증된 사용자는 '좋아요'를 누를 수 있으며, user_id는 본인이어야 합니다.
CREATE POLICY "Allow authenticated users to like posts"
ON public.likes
FOR INSERT
TO authenticated -- INSERT를 시도할 수 있는 역할 (인증된 사용자)
WITH CHECK (user_id = (SELECT auth.uid()));

-- UPDATE Policy
-- (선택적) 명시적으로 모든 UPDATE를 막는 정책 (보통 불필요)
-- CREATE POLICY "Disallow updates to likes"
-- ON public.likes
-- FOR UPDATE
-- USING (false);

-- DELETE Policy
-- 정책 1: 사용자는 자신이 누른 '좋아요'를 취소(삭제)할 수 있습니다.
CREATE POLICY "Allow users to unlike posts (delete their own like)"
ON public.likes
FOR DELETE
TO authenticated -- DELETE를 시도할 수 있는 역할
USING (user_id = (SELECT auth.uid()));

```

19. Newsfeed Image Access Policies
```
-- 1. SELECT Policy (목록 조회 허용)
CREATE POLICY "Allow authenticated users to list newsfeed images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'newsfeed-images'
);

-- 2. INSERT Policy (업로드 허용)
CREATE POLICY "Allow admin to upload newsfeed images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'newsfeed-images' AND
  public.get_user_role(auth.uid()) = 'admin'
);

-- 3. UPDATE Policy (수정 허용, bucket_id 추가)
CREATE POLICY "Allow admin to update own newsfeed images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'newsfeed-images' AND -- bucket_id 체크 추가
  owner_id::uuid = (select auth.uid()) AND
  public.get_user_role(auth.uid()) = 'admin'
);

-- 4. DELETE Policy (삭제 허용, bucket_id 추가)
CREATE POLICY "Allow admin to delete own newsfeed images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'newsfeed-images' AND -- bucket_id 체크 추가
  owner_id::uuid = (select auth.uid()) AND
  public.get_user_role(auth.uid()) = 'admin'
);
```

20. Avatar Management Policy
```
-- public/userId/avatar/uuid.ext
-- 1. avatars 버킷의 파일 목록 조회 정책
CREATE POLICY "Allow authenticated users to list avatars"
ON storage.objects FOR SELECT
TO authenticated
USING ( bucket_id = 'avatars' );

-- 2. 자신의 아바타 이미지 업로드 정책
CREATE POLICY "Allow users to upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);

-- 3. 자신의 아바타 이미지 수정 정책
CREATE POLICY "Allow users to update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);

-- 4. 자신의 아바타 이미지 삭제 정책
CREATE POLICY "Allow users to delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);
```