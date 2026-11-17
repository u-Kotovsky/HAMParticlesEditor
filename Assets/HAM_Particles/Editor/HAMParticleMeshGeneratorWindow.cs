using UnityEngine;
using UnityEditor;
using System.Reflection;
// Code based on ParticleVolumeMeshGeneratorWindow.cs from GPUParticleVolumes
namespace HAMParticles {
    public class HAMParticleMeshGeneratorWindow : EditorWindow {
        private int particleCount = 100;
        private int rowCount = 10;
        private int columnCount = 10;
        private const int MaxParticlesByArraySize = 100000000;

        private static readonly Vector2 DefaultSize = new Vector2(420, 100);

        [MenuItem("Tools/GPU Particle Volumes/HAM Particle Mesh Generator")]
        public static void ShowWindow() {
            var window = GetWindow<HAMParticleMeshGeneratorWindow>(
                false,
                "HAM Particle Mesh Generator",
                true
            );

            // Set initial size but allow resize
            window.position = GetCenteredRect(DefaultSize);

            // No forced fixed size → Unity default resizable window
            window.minSize = new Vector2(300, 120); // Just minimal sane size

            window.Show();
        }

        private void OnGUI() {
            EditorGUILayout.LabelField("Simple Particle Volume Mesh Generator", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            EditorGUI.BeginChangeCheck();
            //particleCount = EditorGUILayout.IntField("Particle Count", particleCount);
            
            rowCount = EditorGUILayout.IntField("Row Count", rowCount);
            columnCount = EditorGUILayout.IntField("Column Count", columnCount);
            
            if (EditorGUI.EndChangeCheck()) {
                //if (particleCount < 1) particleCount = 1;
                //if (particleCount > MaxParticlesByArraySize) particleCount = MaxParticlesByArraySize;
                
                if (rowCount < 1) rowCount = 1;
                if (columnCount < 1) columnCount = 1;
                if (rowCount > MaxParticlesByArraySize) rowCount = MaxParticlesByArraySize/2;
                if (columnCount > MaxParticlesByArraySize) columnCount = MaxParticlesByArraySize/2;
                particleCount = rowCount * columnCount;
            }

            EditorGUILayout.Space();

            if (GUILayout.Button("Generate Mesh and Save...", GUILayout.Height(28))) {
                GenerateAndSave();
            }
        }

        private void GenerateAndSave() {
            string defaultName = $"HAMParticles_{particleCount}_{rowCount}x{columnCount}.asset";

            string path = EditorUtility.SaveFilePanelInProject(
                "Save Particle Mesh",
                defaultName,
                "asset",
                "Choose a location to save the Mesh asset."
            );

            if (string.IsNullOrEmpty(path))
                return;

            try {
                EditorUtility.DisplayProgressBar(
                    "Generating Particle Mesh",
                    "Preparing data...",
                    0f
                );

                Mesh mesh = BuildMeshWithProgress(rowCount, columnCount);

                var existing = AssetDatabase.LoadAssetAtPath<Mesh>(path);
                if (existing != null)
                    AssetDatabase.DeleteAsset(path);

                AssetDatabase.CreateAsset(mesh, path);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                EditorUtility.DisplayDialog("Done", $"Mesh has been saved:\n{path}", "OK");
            } finally {
                EditorUtility.ClearProgressBar();
            }
        }
        
        public static float MapRange(float value, float fromMin, float fromMax, float toMin, float toMax)
        {
            // Clamp input to source range
            value = Mathf.Clamp(value, fromMin, fromMax);

            // Map from source range to 0-1
            float normalized = (value - fromMin) / (fromMax - fromMin);

            // Map from 0-1 to target range
            return toMin + (normalized * (toMax - toMin));
        }
        
        public static int MapRange(int value, int fromMin, int fromMax, int toMin, int toMax)
        {
            // Clamp input to source range
            value = Mathf.Clamp(value, fromMin, fromMax);

            // Map from source range to 0-1
            int normalized = (value - fromMin) / (fromMax - fromMin);

            // Map from 0-1 to target range
            return toMin + (normalized * (toMax - toMin));
        }
        
        private static Mesh BuildMeshWithProgress(int rowCount, int columnCount)
        {
            int particleCount = rowCount * columnCount;
            var mesh = new Mesh();
            mesh.name =  $"HAMParticles_{particleCount}_{rowCount}x{columnCount}";

            int vCount = particleCount * 4;
            int iCount = particleCount * 6;

            if (vCount > 65535)
                mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;

            var verts = new Vector3[vCount];
            var tris = new int[iCount];

            const int step = 10000;
            int i = 0;
            for (int row = 0; row < rowCount; row++)
            {
                for (int col = 0; col < columnCount; col++)
                {
                    if ((i % step) == 0) {
                        EditorUtility.DisplayProgressBar(
                            "Generating Particles Mesh",
                            $"Generating particles: {i}/{particleCount}",
                            (float)i / particleCount
                        );
                    }

                    int v = i * 4;
                    int t = i * 6;

                    Vector3 p = new Vector3(
                        MapRange(row, 0f, rowCount, 0f, 1f),
                        0,
                        MapRange(col, 0f, columnCount, 0f, 1f)
                    );

                    verts[v + 0] = p;
                    verts[v + 1] = p;
                    verts[v + 2] = p;
                    verts[v + 3] = p;

                    tris[t + 0] = v + 0;
                    tris[t + 1] = v + 1;
                    tris[t + 2] = v + 2;
                    tris[t + 3] = v + 2;
                    tris[t + 4] = v + 1;
                    tris[t + 5] = v + 3;
                    i++;
                }
            }
            /*for (int i = 0; i < particleCount; i++) {
                if ((i % step) == 0) {
                    EditorUtility.DisplayProgressBar(
                        "Generating Particles Mesh",
                        $"Generating particles: {i}/{particleCount}",
                        (float)i / particleCount
                    );
                }

                int v = i * 4;
                int t = i * 6;

                int row = i % rowCount;
                int column = i / rowCount;
                

                float rowf = MapRange(row, 0f, rowCount, 0f, 1f);
                float colf = MapRange(row, 0f, rowCount, 0f, 1f);

                Debug.Log($"{row} x {column}, {rowf} {colf}");
                
                Vector3 p = new Vector3(
                    rowf,
                    0,
                    colf
                );

                verts[v + 0] = p;
                verts[v + 1] = p;
                verts[v + 2] = p;
                verts[v + 3] = p;

                tris[t + 0] = v + 0;
                tris[t + 1] = v + 1;
                tris[t + 2] = v + 2;
                tris[t + 3] = v + 2;
                tris[t + 4] = v + 1;
                tris[t + 5] = v + 3;
            }*/

            EditorUtility.DisplayProgressBar(
                "Generating Particles Mesh",
                "Finalizing mesh...",
                1f
            );

            mesh.vertices = verts;
            mesh.triangles = tris;
            //mesh.bounds = new Bounds(Vector3.zero, new Vector3(10000, 10000, 10000));

            return mesh;
        }

        //
        // Utility: center editor window
        //
        private static Rect GetCenteredRect(Vector2 size) {
            Rect main = GetEditorMainWindowRect();
            float w = size.x;
            float h = size.y;

            return new Rect(
                main.x + (main.width - w) * 0.5f,
                main.y + (main.height - h) * 0.5f,
                w,
                h
            );
        }

        // Reflectively get the main editor window rect
        private static Rect GetEditorMainWindowRect() {
            var type = typeof(Editor).Assembly.GetType("UnityEditor.ContainerWindow");
            var showModeField = type?.GetField("m_ShowMode",
                BindingFlags.NonPublic | BindingFlags.Instance);
            var positionProp = type?.GetProperty("position",
                BindingFlags.Public | BindingFlags.Instance);

            if (type == null || showModeField == null || positionProp == null)
                return new Rect(0, 0, 800, 600);

            var windows = Resources.FindObjectsOfTypeAll(type);
            foreach (var win in windows) {
                int showMode = (int)showModeField.GetValue(win);
                if (showMode == 4) // main editor window
                    return (Rect)positionProp.GetValue(win, null);
            }

            return new Rect(0, 0, 800, 600);
        }
    }
}